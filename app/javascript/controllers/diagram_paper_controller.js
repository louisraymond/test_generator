import PaperEditorController from "controllers/paper_editor_controller"

// Diagram-label paper-is-editor (Wave 3).
// Click on the figure to drop a pin at the click coordinates (stored as
// percentages so the pin follows the image on responsive resize).
// Click a pin to remove it.
export default class extends PaperEditorController {
  static targets = ["figure"]

  async drop(event) {
    if (event.target.classList.contains("diagram__pin")) return
    const fig = this.hasFigureTarget ? this.figureTarget : event.currentTarget
    const rect = fig.getBoundingClientRect()
    const x = ((event.clientX - rect.left) / rect.width)  * 100
    const y = ((event.clientY - rect.top)  / rect.height) * 100
    await this._post(
      `/questions/${this.questionIdValue}/options_patch`,
      { options: { add_pin: { x: x.toFixed(2), y: y.toFixed(2) } } },
      "PATCH"
    )
    document.dispatchEvent(new CustomEvent("canvas:dirty"))
  }

  async removePin(event) {
    event.stopPropagation()
    const idx = Number(event.currentTarget.dataset.pinIndex)
    if (Number.isNaN(idx)) return
    await this._post(
      `/questions/${this.questionIdValue}/options_patch`,
      { options: { remove_pin: idx } },
      "PATCH"
    )
    document.dispatchEvent(new CustomEvent("canvas:dirty"))
  }
}
