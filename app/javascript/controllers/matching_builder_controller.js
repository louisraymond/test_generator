import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["left", "right"]
  static values = {
    fieldId: String,
    options: Object
  }

  connect() {
    this.initialised = false
  }

  activate(event) {
    if (!this.field) {
      this.field = document.getElementById(this.fieldIdValue)
    }

    if (!this.initialised) {
      const options = this.optionsValue && Object.keys(this.optionsValue).length > 0 ? this.optionsValue : this.parseFieldValue() || {}
      const left = Array.isArray(options.left) ? options.left : []
      const right = Array.isArray(options.right) ? options.right : []

      this.leftTarget.value = left.join('\n')
      this.rightTarget.value = right.join('\n')
      this.initialised = true
    }

    this.sync()
  }

  changed() {
    this.sync()
  }

  sync() {
    if (!this.field) return
    const left = this.splitLines(this.leftTarget.value)
    const right = this.splitLines(this.rightTarget.value)
    this.field.value = JSON.stringify({ left, right })
  }

  splitLines(text) {
    return text
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
  }

  parseFieldValue() {
    if (!this.field || !this.field.value) return null
    try {
      const parsed = JSON.parse(this.field.value)
      return parsed && typeof parsed === 'object' ? parsed : null
    } catch (error) {
      console.warn('Unable to parse matching options', error)
      return null
    }
  }
}
