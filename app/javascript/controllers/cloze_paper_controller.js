import PaperEditorController from "controllers/paper_editor_controller"

// Cloze paper-is-editor — Priority A variant.
// Click a word in the rendered stem → blank it on the printed paper.
// Click a blanked word again → restore it.
export default class extends PaperEditorController {
  async toggleBlank(event) {
    const word = event.currentTarget
    const idx = Number(word.dataset.wordIndex)
    if (Number.isNaN(idx)) return

    // Optimistic flip.
    word.classList.toggle("is-blanked")

    await this._post(`/questions/${this.questionIdValue}/toggle_blank`, { word_index: idx })
  }
}
