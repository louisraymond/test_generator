import PaperEditorController from "controllers/paper_editor_controller"

// MCQ paper-is-editor — Priority A variant.
// Click an option row on the printed paper → mark it correct.
// A green tick appears in the margin (outside the printable area).
export default class extends PaperEditorController {
  static targets = ["option"]

  async markCorrect(event) {
    const li = event.currentTarget
    const idx = Number(li.dataset.optionIndex)
    if (Number.isNaN(idx)) return

    // Optimistic UI: flip tick locally first.
    this.optionTargets.forEach((el) => el.classList.remove("is-correct"))
    li.classList.add("is-correct")

    await this._post(`/questions/${this.questionIdValue}/toggle_correct`, { index: idx })
  }
}
