import PaperEditorController from "controllers/paper_editor_controller"

// MCQ paper-is-editor — Priority A variant (Wave 3).
//
// Interactions:
//   Click an option row                → mark / unmark correct
//   Shift-click an option row          → toggle the eliminated (strike) flag
//   1..9 when nothing is focused       → mark option N correct
//
// All three paths POST to discrete endpoints; the base class handles
// canvas:dirty dispatch so the preview + autosave indicator update.
export default class extends PaperEditorController {
  static targets = ["option"]

  connect() {
    super.connect()
    this._onKey = this._onKey.bind(this)
    document.addEventListener("keydown", this._onKey)
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKey)
  }

  async markCorrect(event) {
    if (event.shiftKey) return this.markEliminated(event)

    const li = event.currentTarget
    const idx = Number(li.dataset.optionIndex)
    if (Number.isNaN(idx)) return

    const wasCorrect = li.classList.contains("is-correct")
    this.optionTargets.forEach((el) => el.classList.remove("is-correct"))
    if (!wasCorrect) li.classList.add("is-correct")

    await this._post(`/questions/${this.questionIdValue}/toggle_correct`, { index: idx })
  }

  async markEliminated(event) {
    const li = event.currentTarget
    const idx = Number(li.dataset.optionIndex)
    if (Number.isNaN(idx)) return

    li.classList.toggle("is-eliminated")
    await this._post(`/questions/${this.questionIdValue}/toggle_eliminated`, { index: idx })
  }

  _onKey(event) {
    // Only respond to top-level number keys; skip when typing into an input
    // or a contenteditable span.
    const active = document.activeElement
    if (active && (active.isContentEditable || ["INPUT", "TEXTAREA"].includes(active.tagName))) return
    if (event.metaKey || event.ctrlKey || event.altKey) return

    const n = Number(event.key)
    if (!Number.isInteger(n) || n < 1 || n > 9) return
    const target = this.optionTargets[n - 1]
    if (!target) return
    event.preventDefault()
    target.click()
  }
}
