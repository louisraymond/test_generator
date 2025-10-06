import { Controller } from "@hotwired/stimulus"

// Handles module focus behavior: scroll to section and fade out other modules
export default class extends Controller {
    static targets = ["moduleCard", "moduleSection"]

    connect() {
        this.focusedModuleId = null
    }

    focusModule(event) {
        event.stopPropagation()

        const moduleCard = event.currentTarget
        const moduleId = moduleCard.dataset.moduleId

        // Find the corresponding section
        const section = this.moduleSectionTargets.find(
            s => s.dataset.moduleId === moduleId
        )

        if (!section) return

        // Set focused module
        this.focusedModuleId = moduleId

        // Apply fade to all other sections
        this.applyFocus(moduleId)

        // Scroll to the section with smooth behavior
        const offset = 80 // Account for any fixed headers
        const elementPosition = section.getBoundingClientRect().top
        const offsetPosition = elementPosition + window.pageYOffset - offset

        window.scrollTo({
            top: offsetPosition,
            behavior: 'smooth'
        })
    }

    applyFocus(moduleId) {
        // Fade all module sections except the focused one
        this.moduleSectionTargets.forEach(section => {
            if (section.dataset.moduleId === moduleId) {
                section.classList.remove('is-faded')
                section.classList.add('is-focused')
            } else {
                section.classList.add('is-faded')
                section.classList.remove('is-focused')
            }
        })

        // Highlight the focused module card
        this.moduleCardTargets.forEach(card => {
            if (card.dataset.moduleId === moduleId) {
                card.classList.add('is-active')
            } else {
                card.classList.remove('is-active')
            }
        })
    }

    clearFocus() {
        this.focusedModuleId = null

        // Remove fade from all sections
        this.moduleSectionTargets.forEach(section => {
            section.classList.remove('is-faded', 'is-focused')
        })

        // Remove active state from all cards
        this.moduleCardTargets.forEach(card => {
            card.classList.remove('is-active')
        })
    }

    handleBackgroundClick(event) {
        // Only clear focus if clicking on background elements
        // Don't clear if clicking on module cards, sections, or their children
        const clickedOnModule = event.target.closest('[data-module-id]')
        const clickedOnCard = event.target.closest('.module-card')
        const clickedOnSection = event.target.closest('.module-section')

        if (!clickedOnModule && !clickedOnCard && !clickedOnSection && this.focusedModuleId) {
            this.clearFocus()
        }
    }
}