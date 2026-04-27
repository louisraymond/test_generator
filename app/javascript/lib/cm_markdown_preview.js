import { ViewPlugin, Decoration } from "@codemirror/view"
import { syntaxTree }              from "@codemirror/language"
import { RangeSetBuilder }         from "@codemirror/state"

const HIDDEN_SYNTAX = Decoration.mark({ class: "cm-md-syntax-hidden" })

const STYLED = {
  StrongEmphasis: Decoration.mark({ class: "cm-md-bold" }),
  Emphasis:       Decoration.mark({ class: "cm-md-italic" }),
  ATXHeading1:    Decoration.mark({ class: "cm-md-heading-1" }),
  ATXHeading2:    Decoration.mark({ class: "cm-md-heading-2" }),
  ATXHeading3:    Decoration.mark({ class: "cm-md-heading-3" }),
}

const HEADING_NODES = new Set(["ATXHeading1", "ATXHeading2", "ATXHeading3"])

function buildDecorations(view) {
  const builder = new RangeSetBuilder()
  const cursorLine = view.state.doc.lineAt(view.state.selection.main.head).number

  for (const { from, to } of view.visibleRanges) {
    syntaxTree(view.state).iterate({
      from, to,
      enter(node) {
        const span = STYLED[node.name]
        if (!span) return
        const onCursorLine = view.state.doc.lineAt(node.from).number === cursorLine
        builder.add(node.from, node.to, span)
        if (!onCursorLine) {
          if (HEADING_NODES.has(node.name)) {
            // Hide the leading `# ` / `## ` / `### ` (HeaderMark + the space
            // that follows it). The Lezer grammar exposes the marker as the
            // first child node; the trailing space is one character past it.
            const headerMark = node.node.firstChild
            if (headerMark && headerMark.name === "HeaderMark") {
              const hideTo = Math.min(headerMark.to + 1, node.to)
              builder.add(headerMark.from, hideTo, HIDDEN_SYNTAX)
            }
          } else {
            // Hide the leading + trailing inline markers (** or *).
            // For StrongEmphasis the marker length is 2, for Emphasis it's 1.
            const markerLen = node.name === "StrongEmphasis" ? 2 : 1
            builder.add(node.from, node.from + markerLen, HIDDEN_SYNTAX)
            builder.add(node.to - markerLen, node.to, HIDDEN_SYNTAX)
          }
        }
      }
    })
  }
  return builder.finish()
}

export const markdownPreview = ViewPlugin.fromClass(class {
  constructor(view) { this.decorations = buildDecorations(view) }
  update(u) {
    if (u.docChanged || u.selectionSet || u.viewportChanged) {
      this.decorations = buildDecorations(u.view)
    }
  }
}, { decorations: v => v.decorations })
