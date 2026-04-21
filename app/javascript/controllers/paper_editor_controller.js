import { Controller } from "@hotwired/stimulus"

// Base paper-editor behaviour shared across MCQ / Cloze / Diagram / Calc etc.
// Responsibilities:
//   - wire hover affordance on [data-edit] spans
//   - dispatch `canvas:dirty` after successful mutations so the preview
//     turbo-frame reloads
//   - provide a _post helper with CSRF
//
// Per-type controllers (mcq_paper, cloze_paper, ...) extend this class.
export default class extends Controller {
  static values = { questionId: Number }

  connect() {
    this.element.querySelectorAll("[data-edit]").forEach((el) => {
      el.classList.add("paper-editable")
    })
  }

  async _post(url, body = {}) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const resp = await fetch(url, {
      method: "POST",
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
}
