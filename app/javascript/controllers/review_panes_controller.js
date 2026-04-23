import { Controller } from "@hotwired/stimulus"

// Review tab — manages the Student / Marker toggle that appears at
// narrow viewports (< 1200px). At wider widths both panes are visible
// and the toggle is hidden by CSS; the `data-active` value stays in
// sync anyway so a window-resize into narrow mode shows the right pane.
export default class extends Controller {
  static targets = ["tab"]
  static values  = { active: { type: String, default: "student" } }

  connect() {
    this._render()
  }

  switch(event) {
    const pane = event.currentTarget.dataset.pane
    if (pane) {
      this.activeValue = pane
      this._render()
    }
  }

  _render() {
    this.element.dataset.activePane = this.activeValue
    this.tabTargets.forEach((t) => {
      t.classList.toggle("is-active", t.dataset.pane === this.activeValue)
    })
  }
}
