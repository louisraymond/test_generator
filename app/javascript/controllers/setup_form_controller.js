import { Controller } from "@hotwired/stimulus"

// Setup tab (Phase 4): handles repeatable section rows.
// Cloning the last row keeps the Rails `fields_for` indexing consistent —
// the form controller uses a small running counter stored as a data attr on
// the container so re-adds after a delete still produce unique indices.
export default class extends Controller {
  static targets = ["sections"]

  connect() {
    this._nextIndex = this.sectionsTarget.querySelectorAll('.section-row').length
  }

  addSection(event) {
    event.preventDefault()
    const rows = this.sectionsTarget.querySelectorAll('.section-row')
    const template = rows[rows.length - 1]
    if (!template) return

    const clone = template.cloneNode(true)
    const idx = this._nextIndex++

    clone.querySelectorAll('input, select, textarea').forEach((el) => {
      if (el.name) {
        el.name = el.name.replace(/exam_sections_attributes\]\[\d+\]/, `exam_sections_attributes][${idx}]`)
      }
      if (el.id) {
        el.id = el.id.replace(/_exam_sections_attributes_\d+_/, `_exam_sections_attributes_${idx}_`)
      }
      if (el.type !== 'hidden') {
        el.value = ''
      } else if (el.name && el.name.endsWith('[position]')) {
        el.value = idx
      }
    })

    // Letter default: next capital in sequence.
    const letterInput = clone.querySelector('input[name$="[letter]"]')
    if (letterInput) letterInput.value = String.fromCharCode(65 + idx)

    this.sectionsTarget.appendChild(clone)
  }

  removeSection(event) {
    event.preventDefault()
    const row = event.currentTarget.closest('.section-row')
    if (!row) return

    const rows = this.sectionsTarget.querySelectorAll('.section-row')
    if (rows.length <= 1) return  // keep at least one row

    // If the row has an :id input, mark it _destroy for persisted records.
    const idField = row.querySelector('input[name$="[id]"]')
    if (idField && idField.value) {
      const destroy = document.createElement('input')
      destroy.type = 'hidden'
      destroy.name = idField.name.replace('[id]', '[_destroy]')
      destroy.value = '1'
      row.appendChild(destroy)
      row.style.display = 'none'
    } else {
      row.remove()
    }
  }
}
