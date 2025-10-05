import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]
  static values = {
    fieldId: String,
    items: Array
  }

  connect() {
    this.initialised = false
  }

  activate() {
    if (!this.field) {
      this.field = document.getElementById(this.fieldIdValue)
    }

    if (!this.initialised) {
      const items = this.itemsValue.length ? this.itemsValue : this.parseFieldValue() || []
      this.textareaTarget.value = items.join('\n')
      this.initialised = true
    }

    this.sync()
  }

  changed() {
    this.sync()
  }

  sync() {
    if (!this.field) return
    const items = this.textareaTarget.value
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
    this.field.value = JSON.stringify(items)
  }

  parseFieldValue() {
    if (!this.field || !this.field.value) return null
    try {
      const parsed = JSON.parse(this.field.value)
      return Array.isArray(parsed) ? parsed : null
    } catch (error) {
      console.warn('Unable to parse list options', error)
      return null
    }
  }
}
