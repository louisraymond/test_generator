import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "masks"]
  static values = {
    fieldId: String,
    options: Object
  }

  connect() {
    this.initialised = false
  }

  activate() {
    if (!this.field) {
      this.field = document.getElementById(this.fieldIdValue)
    }

    if (!this.initialised) {
      const options = this.optionsValue && Object.keys(this.optionsValue).length > 0 ? this.optionsValue : this.parseFieldValue() || {}
      this.imageTarget.value = options.image || ''
      const masks = Array.isArray(options.masks) ? options.masks : []
      this.masksTarget.value = masks.join('\n')
      this.initialised = true
    }

    this.sync()
  }

  changed() {
    this.sync()
  }

  sync() {
    if (!this.field) return
    const image = this.imageTarget.value.trim()
    const masks = this.masksTarget.value
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
    this.field.value = JSON.stringify({ image, masks })
  }

  parseFieldValue() {
    if (!this.field || !this.field.value) return null
    try {
      const parsed = JSON.parse(this.field.value)
      return parsed && typeof parsed === 'object' ? parsed : null
    } catch (error) {
      console.warn('Unable to parse image occlusion options', error)
      return null
    }
  }
}
