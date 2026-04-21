import { Controller } from "@hotwired/stimulus"

// Inspector rail: Content / Marking / Metadata tab switching.
// Keyboard shortcuts: ⌘1 / ⌘2 / ⌘3 focus tabs; Escape dispatches a
// `canvas:rail-dismiss` event (Phase 7 consumes to restore paper focus).
export default class extends Controller {
  connect() {
    this._onKey = this._onKey.bind(this)
    document.addEventListener("keydown", this._onKey)
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKey)
  }

  switch(event) {
    const tabName = event.currentTarget.dataset.railTab
    this.element.querySelectorAll(".rail-tab").forEach((t) => {
      const active = t.dataset.railTab === tabName
      t.classList.toggle("is-active", active)
      t.setAttribute("aria-selected", active)
    })
    this.element.querySelectorAll(".rail-panel").forEach((p) => {
      p.classList.toggle("is-active", p.dataset.railPanel === tabName)
    })
  }

  _onKey(event) {
    if (!(event.metaKey || event.ctrlKey)) return
    const map = { "1": "content", "2": "marking", "3": "metadata" }
    const tabName = map[event.key]
    if (!tabName) return
    const tab = this.element.querySelector(`.rail-tab[data-rail-tab="${tabName}"]`)
    if (!tab) return
    event.preventDefault()
    tab.click()
    tab.focus()
  }
}
