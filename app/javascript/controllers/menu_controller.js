import { Controller } from "@hotwired/stimulus"

// Handles the responsive site navigation menu.
export default class extends Controller {
    static targets = ["nav", "toggle", "backdrop"]

    connect() {
        this.open = false
        this.update()

        // Close menu on escape key
        this.escapeHandler = this.handleEscape.bind(this)
        document.addEventListener('keydown', this.escapeHandler)
    }

    disconnect() {
        document.removeEventListener('keydown', this.escapeHandler)
    }

    toggle(event) {
        event.preventDefault()
        this.open = !this.open
        this.update()
    }

    close(event) {
        if (!this.open) return
            // Don't prevent default - allow links to navigate
        this.open = false
        this.update()
    }

    handleEscape(event) {
        if (event.key === 'Escape' && this.open) {
            this.close()
        }
    }

    update() {
        const expanded = this.open

        // Update nav
        if (this.hasNavTarget) {
            this.navTarget.classList.toggle("is-open", expanded)
            this.navTarget.setAttribute("aria-hidden", (!expanded).toString())
        }

        // Update toggle button
        if (this.hasToggleTarget) {
            this.toggleTarget.setAttribute("aria-expanded", expanded.toString())
        }

        // Update backdrop
        if (this.hasBackdropTarget) {
            this.backdropTarget.classList.toggle("is-visible", expanded)
        }

        // Prevent body scroll when menu is open
        document.body.classList.toggle("nav-open", expanded)
    }
}