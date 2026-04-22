import PaperEditorController from "controllers/paper_editor_controller"

// Code analysis paper-is-editor (Wave 3).
// Click a rendered code line to toggle its "highlighted" flag — the
// author's way of marking the bug / line under question. Stored as an
// array of integer line indices under options.highlighted_lines.
export default class extends PaperEditorController {
  async toggleLine(event) {
    const span = event.currentTarget
    const line = Number(span.dataset.lineIndex)
    if (Number.isNaN(line)) return
    span.classList.toggle("is-highlighted")
    await this._post(
      `/questions/${this.questionIdValue}/options_patch`,
      { options: { toggle_highlighted_line: line } },
      "PATCH"
    )
  }
}
