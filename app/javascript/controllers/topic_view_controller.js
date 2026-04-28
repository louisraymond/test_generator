import { Controller } from "@hotwired/stimulus"

const VIEWS = ["modules", "categories", "outcomes"]
const SORTS = ["topic_order", "nq_desc", "nq_asc", "alpha"]
const WRITE_DEBOUNCE_MS = 200

// sub-56: view switcher controller. Toggles [hidden] on three pre-rendered panes
// and persists the active view + sort to localStorage (debounced).
// Listens for the v-shortcut via topic-view:cycle (sub-57 dispatch).
export default class extends Controller {
  static targets = ["pane", "tab", "sortSelect"]
  static values = {
    topicId: Number,
    view: { type: String, default: "modules" },
    sort: { type: String, default: "topic_order" }
  }

  connect() {
    this.writeTimer = null
    this.hydrateFromStorage()
    this.render()
    this.applySort()
    // sub-57 dispatches `topic-view:cycle` for the `v` shortcut.
    this.cycleHandler = (_event) => this.cycleView()
    this.element.addEventListener("topic-view:cycle", this.cycleHandler)
  }

  disconnect() {
    if (this.writeTimer) clearTimeout(this.writeTimer)
    if (this.cycleHandler) this.element.removeEventListener("topic-view:cycle", this.cycleHandler)
  }

  hydrateFromStorage() {
    try {
      const v = localStorage.getItem(this.viewKey)
      const s = localStorage.getItem(this.sortKey)
      if (VIEWS.includes(v)) this.viewValue = v
      if (SORTS.includes(s)) this.sortValue = s
    } catch (_e) {
      // localStorage may throw if disabled / quota exceeded — fall back to in-memory.
    }
  }

  get viewKey() { return `topic-detail:topic-${this.topicIdValue}:view` }
  get sortKey() { return `topic-detail:topic-${this.topicIdValue}:sort` }

  cycleView() {
    const next = VIEWS[(VIEWS.indexOf(this.viewValue) + 1) % VIEWS.length]
    this.viewValue = next
  }

  selectView(event) {
    const v = event.currentTarget?.dataset?.view
    if (VIEWS.includes(v)) this.viewValue = v
  }

  selectSort(event) {
    const s = event.currentTarget?.value
    if (SORTS.includes(s)) {
      this.sortValue = s
    }
  }

  viewValueChanged() {
    this.render()
    this.persist()
    this.focusFirstHeading()
    this.dispatch("changed", { detail: { view: this.viewValue } })
    // Re-apply any live search query against the freshly visible DOM.
    this.dispatchToSearch()
  }

  sortValueChanged() {
    this.applySort()
    this.persist()
  }

  render() {
    if (!this.hasPaneTarget) return
    this.paneTargets.forEach((pane) => {
      pane.hidden = pane.dataset.view !== this.viewValue
    })
    if (this.hasTabTarget) {
      this.tabTargets.forEach((tab) => {
        const selected = tab.dataset.view === this.viewValue
        tab.setAttribute("aria-selected", selected ? "true" : "false")
      })
    }
  }

  applySort() {
    if (!this.hasPaneTarget) return
    const pane = this.paneTargets.find((p) => p.dataset.view === "outcomes")
    if (!pane) return
    const list = pane.querySelector("[data-outcomes-flat]")
    if (!list) return

    const rows = Array.from(list.querySelectorAll("[data-outcome-row]"))
    const cmp = this.comparatorFor(this.sortValue)
    rows.sort(cmp).forEach((row) => list.appendChild(row))
    if (this.hasSortSelectTarget && this.sortSelectTarget.value !== this.sortValue) {
      this.sortSelectTarget.value = this.sortValue
    }
  }

  comparatorFor(sort) {
    switch (sort) {
      case "nq_desc": return (a, b) => Number(b.dataset.nq) - Number(a.dataset.nq)
      case "nq_asc":  return (a, b) => Number(a.dataset.nq) - Number(b.dataset.nq)
      case "alpha":   return (a, b) => (a.dataset.loText || "").localeCompare(b.dataset.loText || "")
      default:        return (a, b) => Number(a.dataset.topicOrder) - Number(b.dataset.topicOrder)
    }
  }

  persist() {
    if (this.writeTimer) clearTimeout(this.writeTimer)
    this.writeTimer = setTimeout(() => {
      try {
        localStorage.setItem(this.viewKey, this.viewValue)
        localStorage.setItem(this.sortKey, this.sortValue)
      } catch (_e) {
        // localStorage disabled / full — ignore.
      }
    }, WRITE_DEBOUNCE_MS)
  }

  focusFirstHeading() {
    if (!this.hasPaneTarget) return
    const pane = this.paneTargets.find((p) => p.dataset.view === this.viewValue)
    if (!pane) return
    const heading = pane.querySelector("h2, h3")
    if (heading) {
      heading.setAttribute("tabindex", "-1")
      heading.focus({ preventScroll: false })
    }
  }

  dispatchToSearch() {
    const search = this.application.getControllerForElementAndIdentifier(this.element, "topic-search")
    if (search && typeof search.reapply === "function") search.reapply()
  }
}
