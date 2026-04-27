import { ViewPlugin, Decoration } from "@codemirror/view"
import { syntaxTree }              from "@codemirror/language"
import { RangeSetBuilder }         from "@codemirror/state"

const HIDDEN_SYNTAX = Decoration.mark({ class: "cm-md-syntax-hidden" })

const STYLED = {
  StrongEmphasis: Decoration.mark({ class: "cm-md-bold" }),
  Emphasis:       Decoration.mark({ class: "cm-md-italic" }),
}

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
          // Hide the leading + trailing markdown markers (** or *).
          // For StrongEmphasis the marker length is 2, for Emphasis it's 1.
          const markerLen = node.name === "StrongEmphasis" ? 2 : 1
          builder.add(node.from, node.from + markerLen, HIDDEN_SYNTAX)
          builder.add(node.to - markerLen, node.to, HIDDEN_SYNTAX)
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
