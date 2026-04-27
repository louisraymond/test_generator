import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { questionId: Number }

  async addAfter(event) {
    const partEl = event.target.closest("[data-part-index]")
    const after  = Number(partEl.dataset.partIndex)
    const token  = document.querySelector('meta[name="csrf-token"]')?.content

    const res = await fetch(`/questions/${this.questionIdValue}/options_patch`, {
      method:  "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token || "",
        "Accept":       "text/html",   // server returns the re-rendered composite block
      },
      body: JSON.stringify({ options: { add_part: { after } } }),
    })
    if (!res.ok) return

    // Server returns the freshly-rendered composite root. Replace the existing
    // <ol data-composite-root>; Stimulus will auto-connect new cm-editor
    // controllers on the new <li> elements.
    const html = await res.text()
    const root = document.querySelector("[data-composite-root]")
    const wrapper = document.createElement("div")
    wrapper.innerHTML = html
    const fresh = wrapper.querySelector("[data-composite-root]")
    if (root && fresh) root.replaceWith(fresh)
  }
}
