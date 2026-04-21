import { Controller } from "@hotwired/stimulus"

// Canvas tab (Phase 5 shell).
// Wires the question list to the preview frame and rail.
// Debounced reload on edits is implemented via Turbo Frame `src` re-assign
// once Phase 6-7 dispatch `canvas:dirty` events.
export default class extends Controller {
  static targets = ["frame", "rail", "railBody"]
  static values = { examId: Number }

  connect() {
    this.reloadFrame = this._debounce(this.reloadFrame.bind(this), 200)
    document.addEventListener("canvas:dirty", this.reloadFrame)
  }

  disconnect() {
    document.removeEventListener("canvas:dirty", this.reloadFrame)
  }

  reloadFrame() {
    if (!this.hasFrameTarget) return
    const src = this.frameTarget.getAttribute("src")
    if (!src) return
    // Forcing reload by re-setting src ensures Turbo refetches even for
    // identical URL with the same query string.
    this.frameTarget.setAttribute("src", `${src.split("?")[0]}?t=${Date.now()}`)
  }

  selectQuestion(event) {
    const item = event.target.closest(".qlist-item")
    if (!item) return
    this.element.querySelectorAll(".qlist-item.is-active").forEach((el) => el.classList.remove("is-active"))
    item.classList.add("is-active")
    // Phase 6 wires the rail to render the selected question's inspector here.
    if (this.hasRailBodyTarget) {
      this.railBodyTarget.dataset.activeEqId = item.dataset.eqId || ""
    }
  }

  _debounce(fn, delay) {
    let t
    return (...args) => {
      clearTimeout(t)
      t = setTimeout(() => fn.apply(this, args), delay)
    }
  }
}
