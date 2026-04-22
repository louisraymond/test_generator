import PaperEditorController from "controllers/paper_editor_controller"

// Ordering / Ranking paper-is-editor (Wave 3).
// Authors edit the item text inline (base class); drag-reorder updates the
// canonical order. Ranking variant also pins a `rank` per item — same wire,
// different read on the rail side.
export default class extends PaperEditorController {
  static targets = ["list"]

  dragStart(event) {
    const li = event.currentTarget
    this._draggedIndex = Number(li.dataset.originalIndex)
    event.dataTransfer.effectAllowed = "move"
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  async drop(event) {
    event.preventDefault()
    const li = event.currentTarget
    const target = Number(li.dataset.originalIndex)
    if (this._draggedIndex === undefined || this._draggedIndex === target) return
    await this._post(
      `/questions/${this.questionIdValue}/options_patch`,
      { options: { reorder: { from: this._draggedIndex, to: target } } },
      "PATCH"
    )
    // Let the canvas preview re-render.
    document.dispatchEvent(new CustomEvent("canvas:dirty"))
  }
}
