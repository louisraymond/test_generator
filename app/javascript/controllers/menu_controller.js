import { Controller } from "@hotwired/stimulus"

// Handles the responsive site navigation menu.
export default class extends Controller {
  static targets = ["nav", "toggle"]

  connect() {
    this.open = false
    this.update()
  }

  toggle(event) {
    event.preventDefault()
    this.open = !this.open
    this.update()
  }

  close() {
    if (!this.open) return
    this.open = false
    this.update()
  }

  update() {
    const expanded = this.open
    if (this.hasNavTarget) {
      this.navTarget.classList.toggle("is-open", expanded)
      const usesDrawer = window.matchMedia("(max-width: 768px)").matches
      if (usesDrawer) {
        this.navTarget.setAttribute("aria-hidden", (!expanded).toString())
      } else {
        this.navTarget.removeAttribute("aria-hidden")
      }
    }
    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-expanded", expanded)
    }
    document.body.classList.toggle("nav-open", expanded)
  }
}
