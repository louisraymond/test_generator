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
    const html = this.templateTarget.innerHTML.replace(/NEW_INDEX/g, this.counter)
    const wrapper = document.createElement("div")
    wrapper.innerHTML = html
    const row = wrapper.firstElementChild
    this.listTarget.appendChild(row)
    this.counter += 1
    this.reindex()
    this.sync()
  }

  removeOption(event) {
    event.preventDefault()
    const index = event.currentTarget.dataset.index
    const row = this.listTarget.querySelector(`.ranking-option-row[data-index='${index}']`)
    if (row && this.listTarget.children.length > 1) {
      row.remove()
      this.reindex()
      this.sync()
    }
  }

  updateOption() {
    this.sync()
  }

  reindex() {
    const rows = Array.from(this.listTarget.querySelectorAll('.ranking-option-row'))
    rows.forEach((row, idx) => {
      const index = String(idx)
      row.dataset.index = index

      const textarea = row.querySelector('.ranking-option-textarea')
      if (textarea) {
        textarea.id = `ranking-option-${index}`
        textarea.name = `question[ranking_options][${index}][text]`
        const label = row.querySelector('label.hint')
        if (label) {
          label.htmlFor = textarea.id
          label.textContent = `Option ${idx + 1}`
        }
      }

      const numberInput = row.querySelector('.ranking-option-rank-input')
      if (numberInput) {
        numberInput.name = `question[ranking_options][${index}][rank]`
      }

      const removeButton = row.querySelector('.ranking-option-remove')
      if (removeButton) {
        removeButton.dataset.index = index
      }
    })
  }

  sync() {
    if (!this.field) return
    const rows = Array.from(this.listTarget.querySelectorAll('.ranking-option-row'))
    const formatted = rows.map((row, idx) => {
      const text = row.querySelector('.ranking-option-textarea')?.value?.trim() || ''
      const rankValue = row.querySelector('.ranking-option-rank-input')?.value
      const rank = parseInt(rankValue, 10)
      return { text, rank: Number.isFinite(rank) && rank > 0 ? rank : idx + 1 }
    }).filter((item) => item.text.length > 0)

    this.field.value = JSON.stringify(formatted)
  }
}
