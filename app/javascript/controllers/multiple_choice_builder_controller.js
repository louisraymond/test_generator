import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]
  static values = {
    fieldId: String
  }

  connect() {
    this.field = document.getElementById(this.fieldIdValue)
    this.counter = this.listTarget.children.length
    this.sync()
  }

  activate() {
    if (!this.field || !document.body.contains(this.field)) {
      this.field = document.getElementById(this.fieldIdValue)
    }
    this.sync()
  }

  addOption(event) {
    event.preventDefault()
    const fragment = this.templateTarget.innerHTML.replace(/NEW_INDEX/g, this.counter)
    const wrapper = document.createElement("div")
    wrapper.innerHTML = fragment
    const optionRow = wrapper.firstElementChild
    this.listTarget.appendChild(optionRow)
    this.counter += 1
    this.reindex()
    this.sync()
  }

  removeOption(event) {
    event.preventDefault()
    const index = event.currentTarget.dataset.index
    const row = this.listTarget.querySelector(`.mc-option-row[data-index='${index}']`)
    if (row && this.listTarget.children.length > 2) {
      row.remove()
      this.reindex()
      this.sync()
    }
  }

  updateOption() {
    this.sync()
  }

  reindex() {
    const rows = Array.from(this.listTarget.querySelectorAll('.mc-option-row'))
    rows.forEach((row, idx) => {
      const idxString = String(idx)
      row.dataset.index = idxString

      const textarea = row.querySelector('.mc-option-textarea')
      if (textarea) {
        textarea.id = `mc-option-${idxString}`
        textarea.name = `question[multi_choice_options][${idxString}][text]`
        const label = row.querySelector('label.hint')
        if (label) {
          label.htmlFor = textarea.id
          label.textContent = `Option ${idx + 1}`
        }
      }

      const hidden = row.querySelector("input[type='hidden']")
      if (hidden) {
        hidden.name = `question[multi_choice_options][${idxString}][correct]`
      }

      const checkbox = row.querySelector("input[type='checkbox']")
      if (checkbox) {
        checkbox.name = `question[multi_choice_options][${idxString}][correct]`
      }

      const removeButton = row.querySelector('.mc-option-remove')
      if (removeButton) {
        removeButton.dataset.index = idxString
      }
    })
  }

  sync() {
    if (!this.field) return

    const rows = Array.from(this.listTarget.querySelectorAll('.mc-option-row'))
    const formatted = rows.map((row) => {
      const text = row.querySelector('.mc-option-textarea')?.value?.trim() || ''
      const checkbox = row.querySelector("input[type='checkbox']")
      return { text, correct: checkbox ? checkbox.checked : false }
    }).filter((item) => item.text.length > 0)

    this.field.value = JSON.stringify(formatted)
  }
}
