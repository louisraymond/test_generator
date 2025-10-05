import { Controller } from "@hotwired/stimulus"

// Coordinates topic-based learning outcome selection and type-specific option panels.
export default class extends Controller {
  static targets = [
    "topicSelect",
    "group",
    "checkbox",
    "summary",
    "typeSelect",
    "panel",
    "optionsField"
  ]

  connect() {
    this.topicChanged()
    this.typeChanged()
  }

  topicChanged() {
    const topicId = this.topicSelectTarget.value

    this.groupTargets.forEach((group) => {
      const matches = group.dataset.topicId === topicId && topicId !== ""
      group.classList.toggle("is-active", matches)

      const checkboxes = group.querySelectorAll("input[type='checkbox']")
      checkboxes.forEach((checkbox) => {
        if (!matches) {
          checkbox.checked = false
        }
        checkbox.disabled = !matches
      })
    })

    this.updateSummary()
  }

  updateSummary() {
    const checked = this.checkboxTargets.filter((checkbox) => checkbox.checked && !checkbox.disabled)

    if (checked.length === 0) {
      this.summaryTarget.textContent = this.topicSelectTarget.value ? 'No outcomes selected yet.' : 'Select a topic to view outcomes.'
      return
    }

    const labels = checked.map((checkbox) => {
      const label = checkbox.closest('.lo-checkbox')?.querySelector('.lo-checkbox__label')
      return label ? label.textContent.trim() : ''
    }).filter(Boolean)

    this.summaryTarget.textContent = labels.join(', ')
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
