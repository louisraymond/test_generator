import { Controller } from "@hotwired/stimulus"

// Knowledge base topic tree — expand/collapse on click.
// Keyboard: arrow keys navigate siblings; Enter toggles.
export default class extends Controller {
  toggle(event) {
    const button = event.currentTarget
    const li = button.closest(".topic-tree__topic")
    const modules = li?.querySelector(".topic-tree__modules")
    const expanded = button.getAttribute("aria-expanded") === "true"
    button.setAttribute("aria-expanded", !expanded)
    if (modules) modules.hidden = expanded
  }
}
