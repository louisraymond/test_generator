import { Controller } from "@hotwired/stimulus"

// Generic wizard controller — used by the Generator (Wave 4.1),
// Template Builder (4.2), and Topic Editor (4.3). Pure step
// visibility; the form itself is any child form_with.
export default class extends Controller {
  static values = { step: Number }
  static targets = ["panel", "tab"]

  connect() {
    if (!this.hasStepValue || this.stepValue === 0) this.stepValue = 1
    this._render()
  }

  goTo(event) {
    const step = Number(event.currentTarget.dataset.wizardStep)
    if (!Number.isNaN(step)) {
      this.stepValue = step
      this._render()
    }
  }

  next() {
    this.stepValue = Math.min(this.stepValue + 1, this.panelTargets.length)
    this._render()
  }

  prev() {
    this.stepValue = Math.max(this.stepValue - 1, 1)
    this._render()
  }

  _render() {
    this.panelTargets.forEach((p) => {
      const n = Number(p.dataset.wizardStep)
      p.classList.toggle("is-active", n === this.stepValue)
    })
    this.tabTargets.forEach((t) => {
      const n = Number(t.dataset.wizardStep)
      t.classList.toggle("is-active", n === this.stepValue)
      t.classList.toggle("is-complete", n < this.stepValue)
    })
  }
}
