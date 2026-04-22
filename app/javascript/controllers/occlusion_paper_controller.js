import PaperEditorController from "controllers/paper_editor_controller"

// Image occlusion paper-is-editor (Wave 3).
// Click-drag to draw a mask rectangle over the figure. Click an existing
// mask to remove it. Masks stored as percentages of the figure width/height.
export default class extends PaperEditorController {
  static targets = ["figure"]

  connect() {
    super.connect()
    this._drawing = null
  }

  startMask(event) {
    if (event.target.classList.contains("occlusion__mask")) return
    const fig = this.figureTarget
    const rect = fig.getBoundingClientRect()
    this._drawing = {
      x0: ((event.clientX - rect.left) / rect.width)  * 100,
      y0: ((event.clientY - rect.top)  / rect.height) * 100,
      rect: rect
    }
  }

  trackMask(event) {
    if (!this._drawing) return
    // Visual marquee deferred — server round-trips on mouseup keep the
    // controller small.
  }

  async endMask(event) {
    if (!this._drawing) return
    const rect = this._drawing.rect
    const x1 = ((event.clientX - rect.left) / rect.width)  * 100
    const y1 = ((event.clientY - rect.top)  / rect.height) * 100
    const x = Math.min(this._drawing.x0, x1).toFixed(2)
    const y = Math.min(this._drawing.y0, y1).toFixed(2)
    const w = Math.abs(x1 - this._drawing.x0).toFixed(2)
    const h = Math.abs(y1 - this._drawing.y0).toFixed(2)
    this._drawing = null
    if (Number(w) < 2 || Number(h) < 2) return
    await this._post(
      `/questions/${this.questionIdValue}/options_patch`,
      { options: { add_mask: { x, y, w, h } } },
      "PATCH"
    )
    document.dispatchEvent(new CustomEvent("canvas:dirty"))
  }

  async removeMask(event) {
    event.stopPropagation()
    const idx = Number(event.currentTarget.dataset.maskIndex)
    if (Number.isNaN(idx)) return
    await this._post(
      `/questions/${this.questionIdValue}/options_patch`,
      { options: { remove_mask: idx } },
      "PATCH"
    )
    document.dispatchEvent(new CustomEvent("canvas:dirty"))
  }
}
