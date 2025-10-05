import { Controller } from "@hotwired/stimulus"

// Manages dynamic learning objective fields within the topic form.
export default class extends Controller {
  static targets = ["list", "template", "item"]
  static values = { index: Number }

  connect() {
    if (!this.hasIndexValue) {
      this.indexValue = this.itemTargets.length
    }
  }

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_OBJECTIVE/g, this.indexValue)
    this.listTarget.insertAdjacentHTML("beforeend", content)
    this.indexValue += 1
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest("[data-objective-list-target='item']")
    if (!wrapper) return

    const destroyField = wrapper.querySelector("input[name$='[_destroy]']")
    const idField = wrapper.querySelector("input[name$='[id]']")

    if (destroyField && idField && idField.value) {
      destroyField.value = "1"
      wrapper.dataset.removed = "true"
      wrapper.style.display = "none"
    } else {
      wrapper.remove()
    }

    if (this.visibleItems().length === 0) {
      this.add(event)
    }
  }

  visibleItems() {
    return Array.from(this.listTarget.querySelectorAll("[data-objective-list-target='item']"))
      .filter((node) => node.dataset.removed !== "true")
  }
}
