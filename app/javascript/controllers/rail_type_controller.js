import { Controller } from "@hotwired/stimulus"

// Hooks for rail-side per-type controls (e.g. Matching "Re-seed").
// Small footprint — just POSTs to /questions/:id/options_patch.
export default class extends Controller {
  async reseed(event) {
    const id = event.params.questionId || event.currentTarget.dataset.questionId
    if (!id) return
    const seed = Math.floor(Math.random() * 99999)
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    await fetch(`/questions/${id}/options_patch`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token || "",
        "Accept": "application/json"
      },
      body: JSON.stringify({ options: { seed } })
    })
    document.dispatchEvent(new CustomEvent("canvas:dirty"))
  }
}
