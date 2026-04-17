import { Controller } from "@hotwired/stimulus"

// Drives the code_analysis question form panel:
// - Toggles the Choices section based on the answer_format radios
// - Handles dynamic add/remove/reindex of choice rows
//
// Does NOT write to the hidden options_text field — server-side
// `serialize_code_analysis` in QuestionsController is the authority.
export default class extends Controller {
  static targets = ["choicesSection", "choicesList", "choiceTemplate"]
  static values = { fieldId: String }

  connect() {
    this.counter = this.choicesListTarget.children.length
    this.updateVisibility()
  }

  answerFormatChanged() {
    this.updateVisibility()
  }

  updateVisibility() {
    const radio = this.element.querySelector(
      'input[name="question[code_analysis][answer_format]"]:checked'
    )
    const fmt = radio ? radio.value : 'lines'
    this.choicesSectionTarget.hidden = fmt !== 'multiple_choice'
  }

  addChoice(event) {
    event.preventDefault()
    const fragment = this.choiceTemplateTarget.innerHTML.replace(/NEW_INDEX/g, this.counter)
    const wrapper = document.createElement("div")
    wrapper.innerHTML = fragment
    const row = wrapper.firstElementChild
    this.choicesListTarget.appendChild(row)
    this.counter += 1
    this.reindex()
  }

  removeChoice(event) {
    event.preventDefault()
    const index = event.currentTarget.dataset.index
    const row = this.choicesListTarget.querySelector(`.mc-option-row[data-index='${index}']`)
    if (row && this.choicesListTarget.children.length > 2) {
      row.remove()
      this.reindex()
    }
  }

  reindex() {
    const rows = Array.from(this.choicesListTarget.querySelectorAll('.mc-option-row'))
    rows.forEach((row, idx) => {
      const idxString = String(idx)
      row.dataset.index = idxString

      const textarea = row.querySelector('.ca-choice-textarea')
      if (textarea) {
        textarea.id = `ca-choice-${idxString}`
        textarea.name = `question[code_analysis][choices][${idxString}][text]`
        const label = row.querySelector('label.hint')
        if (label) {
          label.htmlFor = textarea.id
          label.textContent = `Choice ${String.fromCharCode('A'.charCodeAt(0) + idx)}`
        }
      }

      const hidden = row.querySelector("input[type='hidden']")
      if (hidden) {
        hidden.name = `question[code_analysis][choices][${idxString}][correct]`
      }

      const checkbox = row.querySelector("input[type='checkbox']")
      if (checkbox) {
        checkbox.name = `question[code_analysis][choices][${idxString}][correct]`
      }

      const removeButton = row.querySelector('.mc-option-remove')
      if (removeButton) {
        removeButton.dataset.index = idxString
      }
    })
  }
}
