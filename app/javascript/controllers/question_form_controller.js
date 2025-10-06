import { Controller } from "@hotwired/stimulus"

// Coordinates topic-based learning outcome selection and type-specific option panels.
export default class extends Controller {
    static targets = [
        "topicSelect",
        "group",
        "loSearch",
        "dropdown",
        "dropdownMenu",
        "selectedCount",
        "typeSelect",
        "panel",
        "optionsField"
    ]

    connect() {
        this.topicChanged()
        this.typeChanged()

        // Close dropdown when clicking outside
        this.handleClickOutside = (e) => {
            if (!e.target.closest('.lo-dropdown')) {
                this.closeAllDropdowns()
            }
        }
        document.addEventListener('click', this.handleClickOutside)
    }

    disconnect() {
        document.removeEventListener('click', this.handleClickOutside)
    }

    topicChanged() {
        const topicId = this.topicSelectTarget.value

        this.groupTargets.forEach((group) => {
            const matches = group.dataset.topicId === topicId && topicId !== ""
            group.classList.toggle("is-active", matches)

            if (!matches) {
                // Clear checkboxes when switching topics
                const checkboxes = group.querySelectorAll('.lo-item__checkbox')
                checkboxes.forEach(cb => cb.checked = false)

                // Clear search
                const search = group.querySelector('.lo-dropdown__input')
                if (search) search.value = ''

                // Show all items
                const items = group.querySelectorAll('.lo-item, .lo-category')
                items.forEach(item => item.style.display = '')

                // Close dropdown
                const menu = group.querySelector('.lo-dropdown__menu')
                if (menu) menu.classList.remove('is-open')

                // Reset count
                this.updateCountForGroup(group)
            }
        })
    }

    toggleDropdown(event) {
        event.stopPropagation()
        const dropdown = event.target.closest('.lo-dropdown')
        const menu = dropdown.querySelector('.lo-dropdown__menu')
        menu.classList.toggle('is-open')
    }

    openDropdown(event) {
        event.stopPropagation()
        const dropdown = event.target.closest('.lo-dropdown')
        const menu = dropdown.querySelector('.lo-dropdown__menu')
        menu.classList.add('is-open')
    }

    closeAllDropdowns() {
        this.dropdownMenuTargets.forEach(menu => {
            menu.classList.remove('is-open')
        })
    }

    updateCount(event) {
        const group = event.target.closest('.lo-topic-group')
        this.updateCountForGroup(group)
    }

    updateCountForGroup(group) {
        if (!group) return

        const checkboxes = group.querySelectorAll('.lo-item__checkbox:checked')
        const count = checkboxes.length
        const countDisplay = group.querySelector('.lo-dropdown__selected')

        if (countDisplay) {
            countDisplay.textContent = count === 0 ? '0 selected' :
                count === 1 ? '1 selected' :
                `${count} selected`
        }
    }

    filterLos(event) {
        const searchInput = event.target
        const group = searchInput.closest('.lo-topic-group')
        const filter = searchInput.value.toLowerCase().trim()

        const categories = group.querySelectorAll('.lo-category')

        if (!filter) {
            // Show all
            categories.forEach(cat => {
                cat.style.display = ''
                cat.querySelectorAll('.lo-item').forEach(item => item.style.display = '')
            })
            return
        }

        // Filter items
        categories.forEach(cat => {
            const items = cat.querySelectorAll('.lo-item')
            let hasVisibleItems = false

            items.forEach(item => {
                const text = item.dataset.loText || ''
                const matches = text.includes(filter)
                item.style.display = matches ? '' : 'none'
                if (matches) hasVisibleItems = true
            })

            // Hide category if no items match
            cat.style.display = hasVisibleItems ? '' : 'none'
        })
    }

    typeChanged() {
        if (!this.hasTypeSelectTarget) return
        const selectedType = this.typeSelectTarget.value

        this.panelTargets.forEach((panel) => {
            const isActive = panel.dataset.type === selectedType
            panel.classList.toggle('is-active', isActive)

            if (isActive) {
                panel.dispatchEvent(new CustomEvent('question-type:activated', {
                    detail: { optionsField: this.optionsFieldTarget },
                    bubbles: true
                }))
                if (panel.dataset.clearsOptions === 'true') {
                    this.clearOptions()
                }
            }
        })
    }

    panelActivated(event) {
        this.refreshTextareas(event.currentTarget)
    }

    clearOptions() {
        if (this.hasOptionsFieldTarget) {
            this.optionsFieldTarget.value = ''
        }
    }

    refreshTextareas(panel) {
        if (!this.hasOptionsFieldTarget) return
        const value = this.optionsFieldTarget.value || ''
        const textareas = panel.querySelectorAll('[data-question-form-target="optionsTextarea"]')
        textareas.forEach((textarea) => {
            textarea.value = value
        })
    }

    updateOptionsTextarea(event) {
        if (!this.hasOptionsFieldTarget) return
        this.optionsFieldTarget.value = event.target.value
    }
}