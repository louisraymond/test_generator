import { Controller } from "@hotwired/stimulus"

// Base paper-editor behaviour shared across MCQ / Cloze / Diagram / Calc etc.
//
// Responsibilities:
//   - wire hover affordance + contenteditable on [data-edit] spans
//   - commit on blur / Enter, revert on Escape
//   - dispatch `canvas:dirty` so the preview turbo-frame + autosave controller
//     update in lock-step
//   - provide a _post helper with CSRF for discrete type-specific endpoints
//
// Per-type controllers (mcq_paper, cloze_paper, ...) extend this class and
// add their own event listeners on top of the base wiring.
export default class extends Controller {
  static values = {
    questionId:  Number,
    examId:      Number,
    lockVersion: Number,
    debounceMs:  { type: Number, default: 400 }
  }

  connect() {
    this._pending = {}
    this._scheduleSave = this._debounce(
      this._flushSave.bind(this),
      this.hasDebounceMsValue ? this.debounceMsValue : 400
    )
    this.element.querySelectorAll("[data-edit]").forEach((el) => this._wireEditable(el))
  }

  _wireEditable(el) {
    el.classList.add("paper-editable")
    if (!el.hasAttribute("contenteditable")) el.setAttribute("contenteditable", "true")
    el.setAttribute("spellcheck", "false")
    if (!el.dataset.originalText) el.dataset.originalText = el.innerText
    el.addEventListener("blur", this._onTextBlur.bind(this))
    el.addEventListener("keydown", this._onTextKeydown.bind(this))
  }

  _onTextBlur(event) {
    const el = event.currentTarget
    const field = el.dataset.field
    if (!field) return
    const value = el.innerText
    if (value === el.dataset.originalText) return
    el.dataset.originalText = value
    this._pending[field] = value
    this._scheduleSave()
  }

  _onTextKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      event.currentTarget.blur()
    } else if (event.key === "Escape") {
      event.preventDefault()
      event.currentTarget.textContent = event.currentTarget.dataset.originalText || ""
      event.currentTarget.blur()
    }
  }

  async _flushSave() {
    const payload = { ...this._pending }
    this._pending = {}
    if (Object.keys(payload).length === 0) return

    document.dispatchEvent(new CustomEvent("canvas:dirty", {
      detail: { question: { id: this.questionIdValue, ...payload } }
    }))

    if (this.hasExamIdValue) {
      await this._post(`/api/exams/${this.examIdValue}/autosave`, {
        exam: { lock_version: 0 },
        question: { id: this.questionIdValue, ...payload }
      }, "PATCH")
    }
  }

  async _post(url, body = {}, method = "POST") {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const resp = await fetch(url, {
      method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token || "",
        "Accept": "application/json"
      },
      body: JSON.stringify(body)
    })
    if (resp.ok) {
      document.dispatchEvent(new CustomEvent("canvas:dirty"))
    }
    return resp
  }

  _debounce(fn, ms) {
    let t = null
    return (...args) => {
      clearTimeout(t)
      t = setTimeout(() => fn.apply(this, args), ms)
    }
  }
}
