import { Controller } from "@hotwired/stimulus"

// Editor ticket #40 — Save button + dirty indicator chrome.
//
// Listens for cm:dirty / cm:saved events bubbling up from cm-editor
// instances and reflects state on the Save button (`data-dirty`) and
// the state span ("● unsaved" / "✓ saved …").
//
// On user action (button click or Cmd/Ctrl-S) we walk every mounted
// cm-editor on the page and call its public save() method. Each
// controller is itself idempotent — a no-op when its own _dirty is
// false — so it's safe to call them all unconditionally.
export default class extends Controller {
  static targets = ["button", "state"]

  connect() {
    this._dirtyCount = 0
    this._lastSavedAt = null
    this._tickHandle = null
    this._renderState()
    this._scheduleTick()
  }

  disconnect() {
    if (this._tickHandle) {
      clearInterval(this._tickHandle)
      this._tickHandle = null
    }
  }

  // Stimulus action — wired to click on the button and to global Cmd/Ctrl-S.
  save(event) {
    if (event) {
      // Cmd-S would otherwise pop the browser's "save page" dialog.
      if (event.type === "keydown") event.preventDefault()
    }
    const editors = document.querySelectorAll('[data-controller~="cm-editor"]')
    editors.forEach(el => {
      const ctrl = this.application.getControllerForElementAndIdentifier(el, "cm-editor")
      if (ctrl && typeof ctrl.save === "function") ctrl.save()
    })
  }

  // cm:dirty bubbles from a cm-editor instance whenever it transitions
  // clean→dirty. Track the count so saving one editor doesn't prematurely
  // flip the chrome back to "saved" while another is still dirty.
  onDirty(event) {
    this._dirtyCount += 1
    this._renderState()
  }

  onSaved(event) {
    if (this._dirtyCount > 0) this._dirtyCount -= 1
    this._lastSavedAt = Date.now()
    this._renderState()
  }

  _isDirty() { return this._dirtyCount > 0 }

  _renderState() {
    if (this.hasButtonTarget) {
      this.buttonTarget.dataset.dirty = this._isDirty() ? "true" : "false"
    }
    if (!this.hasStateTarget) return

    if (this._isDirty()) {
      const n = this._dirtyCount
      this.stateTarget.textContent = n === 1 ? "● unsaved edit" : `● ${n} unsaved edits`
      return
    }

    if (this._lastSavedAt) {
      this.stateTarget.textContent = `✓ saved ${this._formatAgo(Date.now() - this._lastSavedAt)}`
    } else {
      this.stateTarget.textContent = "✓ saved a moment ago"
    }
  }

  _formatAgo(deltaMs) {
    if (deltaMs < 5_000)        return "just now"
    if (deltaMs < 60_000)       return "a moment ago"
    const mins = Math.floor(deltaMs / 60_000)
    if (mins < 60)              return `${mins}m ago`
    const hrs = Math.floor(mins / 60)
    return `${hrs}h ago`
  }

  _scheduleTick() {
    // Refresh the "Nm ago" copy every 30s so the timestamp stays roughly current.
    this._tickHandle = setInterval(() => this._renderState(), 30_000)
  }
}
