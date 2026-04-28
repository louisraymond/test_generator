import { ViewPlugin, Decoration, WidgetType } from "@codemirror/view"
import { syntaxTree }                          from "@codemirror/language"
import { RangeSetBuilder }                     from "@codemirror/state"

const HIDDEN_SYNTAX = Decoration.mark({ class: "cm-md-syntax-hidden" })

class KatexWidget extends WidgetType {
  constructor(source, displayMode = false) {
    super()
    this.source = source
    this.displayMode = displayMode
  }
  eq(other) { return other.source === this.source && other.displayMode === this.displayMode }
  toDOM() {
    const span = document.createElement("span")
    span.className = this.displayMode ? "cm-md-katex cm-md-katex--block" : "cm-md-katex"
    try {
      // KaTeX is loaded globally via the layout's <script> tag.
      window.katex.render(this.source, span, {
        throwOnError: false,
        displayMode:  this.displayMode,
      })
    } catch (e) {
      span.textContent = this.source
    }
    return span
  }
  ignoreEvent() { return true }
}

// Math span detection: mirror MATH_SPAN_PATTERN from
// app/helpers/markdown_helper.rb so server-rendered preview and editor
// preview agree on what counts as math. The leading `(^|[^\\$])` capture
// in INLINE_MATH avoids matching `$` after a backslash escape or another
// `$` (which belongs to a `$$…$$` block); the trailing `(?!\d)` avoids
// the `$25` currency false-positive.
const INLINE_MATH = /(^|[^\\$])\$([^$\n]+?)\$(?!\d)/g
const BLOCK_MATH  = /\$\$([^$]+?)\$\$/g

const STYLED = {
  StrongEmphasis: Decoration.mark({ class: "cm-md-bold" }),
  Emphasis:       Decoration.mark({ class: "cm-md-italic" }),
  ATXHeading1:    Decoration.mark({ class: "cm-md-heading-1" }),
  ATXHeading2:    Decoration.mark({ class: "cm-md-heading-2" }),
  ATXHeading3:    Decoration.mark({ class: "cm-md-heading-3" }),
  InlineCode:     Decoration.mark({ class: "cm-md-code-inline" }),
}

const HEADING_NODES = new Set(["ATXHeading1", "ATXHeading2", "ATXHeading3"])

function addMathDecorations(view, push, cursorLine) {
  // When the editor is unfocused, treat every line as "off-cursor" so math
  // renders even though `selection.main.head` still reports its last
  // pre-blur position.
  const focused = view.hasFocus
  // Track ranges already covered by display-math widgets so the inline
  // regex doesn't double-decorate `$$…$$`.
  const blockSpans = []

  for (const { from, to } of view.visibleRanges) {
    const text = view.state.sliceDoc(from, to)
    let match

    BLOCK_MATH.lastIndex = 0
    while ((match = BLOCK_MATH.exec(text)) !== null) {
      const start = from + match.index
      const end   = start + match[0].length
      blockSpans.push([start, end])
      const onCursor = focused && view.state.doc.lineAt(start).number === cursorLine
      if (!onCursor) {
        push(start, end, Decoration.replace({
          widget: new KatexWidget(match[1], true),
        }))
      }
    }

    INLINE_MATH.lastIndex = 0
    while ((match = INLINE_MATH.exec(text)) !== null) {
      const start = from + match.index + match[1].length
      const end   = start + match[2].length + 2
      // Skip inline matches that fall inside a `$$…$$` block.
      if (blockSpans.some(([bs, be]) => start >= bs && end <= be)) continue
      const onCursor = focused && view.state.doc.lineAt(start).number === cursorLine
      if (!onCursor) {
        push(start, end, Decoration.replace({
          widget: new KatexWidget(match[2], false),
        }))
      }
    }
  }
}

function buildDecorations(view) {
  const cursorLine = view.state.doc.lineAt(view.state.selection.main.head).number

  // Collect decorations into an array first; RangeSetBuilder requires
  // non-decreasing `from` order, but the syntax-tree pass and the math
  // regex pass produce ranges in different orders, so we sort before
  // committing to a single builder.
  const ranges = []
  const push = (from, to, deco) => ranges.push({ from, to, deco })

  for (const { from, to } of view.visibleRanges) {
    syntaxTree(view.state).iterate({
      from, to,
      enter(node) {
        const span = STYLED[node.name]
        if (!span) return
        const onCursorLine = view.state.doc.lineAt(node.from).number === cursorLine
        push(node.from, node.to, span)
        if (!onCursorLine) {
          if (HEADING_NODES.has(node.name)) {
            // Hide the leading `# ` / `## ` / `### ` (HeaderMark + the space
            // that follows it). The Lezer grammar exposes the marker as the
            // first child node; the trailing space is one character past it.
            const headerMark = node.node.firstChild
            if (headerMark && headerMark.name === "HeaderMark") {
              const hideTo = Math.min(headerMark.to + 1, node.to)
              push(headerMark.from, hideTo, HIDDEN_SYNTAX)
            }
          } else {
            // Hide the leading + trailing inline markers.
            //   StrongEmphasis  → 2-char `**`
            //   Emphasis        → 1-char `*`
            //   InlineCode      → 1-char backtick (single-backtick spans only;
            //                     multi-backtick fences would need a smarter
            //                     length, but the v1 grammar handles `code` here)
            const markerLen = node.name === "StrongEmphasis" ? 2 : 1
            push(node.from, node.from + markerLen, HIDDEN_SYNTAX)
            push(node.to - markerLen, node.to, HIDDEN_SYNTAX)
          }
        }
      }
    })
  }

  addMathDecorations(view, push, cursorLine)

  // RangeSetBuilder requires non-decreasing `from`. Tie-break on `to` so a
  // wider range (e.g. a heading container) precedes its inner marker hides.
  ranges.sort((a, b) => a.from - b.from || a.to - b.to)
  const builder = new RangeSetBuilder()
  for (const { from, to, deco } of ranges) builder.add(from, to, deco)
  return builder.finish()
}

export const markdownPreview = ViewPlugin.fromClass(class {
  constructor(view) {
    this.decorations = buildDecorations(view)
    this.lastFocus = view.hasFocus
    // Force a rebuild on focus change. CM6's ViewUpdate.focusChanged rides
    // on a transaction; in headless tests `view.focus()` lands in a tick
    // after the dispatch has already settled, so we listen on the DOM
    // directly and dispatch a no-op when the focus state actually flips.
    // TODO (#43 follow-up): @codemirror/view 6.26 added EditorView.focusChangeEffect
    // which would replace this DOM-level workaround with an effect-based path.
    // Keeping the DOM listener for now because the existing editor_preview_spec
    // suite relies on the headless-friendly tick ordering it provides.
    this._poke = () => {
      if (view.hasFocus !== this.lastFocus) {
        this.lastFocus = view.hasFocus
        view.dispatch({})
      }
    }
    view.dom.addEventListener("focusin",  this._poke)
    view.dom.addEventListener("focusout", this._poke)
  }
  update(u) {
    if (u.docChanged || u.selectionSet || u.viewportChanged || u.focusChanged) {
      this.decorations = buildDecorations(u.view)
    } else if (u.view.hasFocus !== this.lastFocus) {
      // _poke fires synchronously inside the DOM event; the dispatched
      // empty transaction reaches us with no flags set, but hasFocus has
      // changed — rebuild on that signal.
      this.lastFocus = u.view.hasFocus
      this.decorations = buildDecorations(u.view)
    }
  }
}, { decorations: v => v.decorations })
