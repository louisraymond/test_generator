import { Controller } from "@hotwired/stimulus"

// Workspace autosave — listens for `canvas:dirty` events from per-type
// paper editors and form inputs, debounces POSTs to /api/exams/:id/autosave,
// and mirrors the save state in the meta-nav indicator.
//
// States: idle | dirty | saving | saved | error | conflict
export default class extends Controller {
  static values = { examId: Number, debounce: { type: Number, default: 3000 } }

  connect() {
    this.state = "idle"
    this._onDirty = this._onDirty.bind(this)
    this._flush = this._debounce(this._flush.bind(this), this.debounceValue)
    document.addEventListener("canvas:dirty", this._onDirty)
  }

  disconnect() {
    document.removeEventListener("canvas:dirty", this._onDirty)
  }

  _onDirty(event) {
    this.pending = event.detail || {}
    this._setState("dirty")
    this._flush()
  }

  async _flush() {
    if (!this.examIdValue) return
    this._setState("saving")
    const token = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const resp = await fetch(`/api/exams/${this.examIdValue}/autosave`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": token || "",
          "Accept": "application/json"
        },
        body: JSON.stringify({
          exam: { lock_version: this._currentLockVersion(), ...(this.pending?.exam || {}) },
          question: this.pending?.question
        })
      })

      if (resp.status === 409) {
        this._setState("conflict")
      } else if (resp.ok) {
        const data = await resp.json().catch(() => ({}))
        this._bumpLockVersion(data.lock_version)
        this._setState("saved", data.saved_at)
      } else {
        this._setState("error")
      }
    } catch (_e) {
      this._setState("error")
    }
  }

  _setState(state, savedAt = null) {
    this.state = state
    const el = document.querySelector("[data-meta-autosave]")
    if (!el) return
    el.dataset.state = state
    el.textContent = this._label(state, savedAt)
  }

  _label(state, savedAt) {
    switch (state) {
    case "idle":     return "Idle"
    case "dirty":    return "Unsaved"
    case "saving":   return "Saving…"
    case "saved":
      if (!savedAt) return "Saved"
      const t = new Date(savedAt)
      return `Saved · ${t.getHours()}:${String(t.getMinutes()).padStart(2, "0")}`
    case "error":    return "Save failed — retrying"
    case "conflict": return "Conflict — reload"
    default:         return state
    }
  }

  _currentLockVersion() {
    const el = document.querySelector("[data-exam-lock-version]")
    return el ? Number(el.dataset.examLockVersion) : 0
  }

  _bumpLockVersion(v) {
    if (!v) return
    const el = document.querySelector("[data-exam-lock-version]")
    if (el) el.dataset.examLockVersion = String(v)
  }

  _debounce(fn, delay) {
    let t
    return (...args) => {
      clearTimeout(t)
      t = setTimeout(() => fn.apply(this, args), delay)
    }
  }
}
