import { Controller } from "@hotwired/stimulus"

const DEBOUNCE_MS = 80
const FILTERED_LO = "topic-detail__lo--filtered"
const FILTERED_CAT = "topic-detail__cat--filtered"
const HEAT_HIT = "topic-detail__heat-cell--query-hit"

// sub-56: search controller. Walks already-rendered DOM and toggles classes.
// Reads: [data-mod-name], [data-cat-name], [data-lo-text], [data-lo-id]
// Optionally: [data-heat-lo-id] for sub-54 heat-map cells
export default class extends Controller {
  static targets = ["input", "liveRegion", "emptyState"]
  static values = { query: { type: String, default: "" } }

  connect() {
    this.timer = null
    if (this.queryValue.length > 0) this.applyFilter()
  }

  disconnect() {
    if (this.timer) clearTimeout(this.timer)
  }

  filter() {
    if (this.timer) clearTimeout(this.timer)
    this.timer = setTimeout(() => this.commit(this.inputTarget.value), DEBOUNCE_MS)
  }

  clear() {
    if (this.hasInputTarget) this.inputTarget.value = ""
    this.commit("")
    this.announce("search cleared")
    if (this.hasInputTarget) this.inputTarget.focus()
  }

  // Called by topic-view controller after a view switch.
  reapply() {
    this.applyFilter()
  }

  commit(raw) {
    const normalised = raw.trim().replace(/\s+/g, " ")
    this.queryValue = normalised
    this.applyFilter()
  }

  applyFilter() {
    performance.mark("topic-search:filter:start")

    const q = this.queryValue.toLowerCase()
    const root = this.element

    // Always clear previous heat-map outline state.
    root.querySelectorAll(`.${HEAT_HIT}`).forEach((el) => el.classList.remove(HEAT_HIT))

    if (q.length === 0) {
      this.restoreAllVisible()
      this.announce("")
      this.toggleEmptyState(false)
      this.dispatch("filtered", { detail: { count: null } })
      this.endMeasure()
      return
    }

    const modules = root.querySelectorAll("[data-mod-name]")
    let totalMatches = 0

    modules.forEach((modEl) => {
      const modName = (modEl.dataset.modName || "").toLowerCase()
      const modMatch = modName.includes(q)
      const cats = modEl.querySelectorAll("[data-cat-name]")
      let modCount = 0

      cats.forEach((catEl) => {
        const catName = (catEl.dataset.catName || "").toLowerCase()
        const catMatch = modMatch || catName.includes(q)
        const los = catEl.querySelectorAll("[data-lo-text]")
        let catCount = 0

        los.forEach((loEl) => {
          const loText = (loEl.dataset.loText || "").toLowerCase()
          const loMatch = catMatch || loText.includes(q)
          loEl.classList.toggle(FILTERED_LO, !loMatch)
          if (loMatch) {
            catCount += 1
            const loId = loEl.dataset.loId
            if (loId) {
              const heatCell = root.querySelector(`[data-heat-lo-id="${loId}"]`)
              if (heatCell) heatCell.classList.add(HEAT_HIT)
            }
          }
        })

        catEl.classList.toggle(FILTERED_CAT, catCount === 0)
        modCount += catCount
      })

      this.paintMatchCount(modEl, modCount)
      totalMatches += modCount
    })

    // Walk standalone LOs (categories pane, outcomes-flat pane) that live
    // outside the [data-mod-name] tree. These match on lo-text + cat-name only.
    const otherCats = root.querySelectorAll("[data-cat-name]:not([data-mod-name] [data-cat-name])")
    otherCats.forEach((catEl) => {
      const catName = (catEl.dataset.catName || "").toLowerCase()
      const catMatch = catName.includes(q)
      const los = catEl.querySelectorAll("[data-lo-text]")
      let catCount = 0
      los.forEach((loEl) => {
        const loText = (loEl.dataset.loText || "").toLowerCase()
        const loMatch = catMatch || loText.includes(q)
        loEl.classList.toggle(FILTERED_LO, !loMatch)
        if (loMatch) {
          catCount += 1
          totalMatches += 1
        }
      })
      catEl.classList.toggle(FILTERED_CAT, catCount === 0)
    })

    // Standalone LOs with no enclosing [data-cat-name] (the flat outcomes list).
    const flatLos = root.querySelectorAll("[data-lo-text]")
    flatLos.forEach((loEl) => {
      // Skip if already handled by a module or category container above.
      if (loEl.closest("[data-mod-name]")) return
      if (loEl.closest("[data-cat-name]")) return
      const loText = (loEl.dataset.loText || "").toLowerCase()
      const loMatch = loText.includes(q)
      loEl.classList.toggle(FILTERED_LO, !loMatch)
      if (loMatch) totalMatches += 1
    })

    this.toggleEmptyState(totalMatches === 0)
    this.announce(`${totalMatches} ${totalMatches === 1 ? "outcome matches" : "outcomes match"}`)
    this.dispatch("filtered", { detail: { count: totalMatches } })

    this.endMeasure()
  }

  endMeasure() {
    performance.mark("topic-search:filter:end")
    try {
      performance.measure("topic-search:filter", "topic-search:filter:start", "topic-search:filter:end")
    } catch (_e) {
      // Older browsers may throw if a mark is missing — non-fatal.
    }
  }

  paintMatchCount(modEl, count) {
    const badge = modEl.querySelector(".topic-detail__module-card__match-count")
    if (!badge) return
    badge.dataset.state = count === 0 ? "zero" : "hit"
    badge.textContent = count === 0 ? "0 matches" : `· ${count} matches`
    if (count === 0) {
      this.collapseModule(modEl)
    } else {
      this.expandModule(modEl)
    }
  }

  collapseModule(modEl) {
    const body = modEl.querySelector(".topic-detail__module-card__body")
    if (body) body.hidden = true
  }

  expandModule(modEl) {
    const body = modEl.querySelector(".topic-detail__module-card__body")
    if (body) body.hidden = false
  }

  restoreAllVisible() {
    const root = this.element
    root.querySelectorAll(`.${FILTERED_LO}`).forEach((el) => el.classList.remove(FILTERED_LO))
    root.querySelectorAll(`.${FILTERED_CAT}`).forEach((el) => el.classList.remove(FILTERED_CAT))
    root.querySelectorAll(".topic-detail__module-card__match-count").forEach((el) => {
      el.textContent = ""
      delete el.dataset.state
    })
    // Hand expand/collapse state back to topic-detail (sub-55 reads localStorage).
    this.dispatch("restore-expansion")
  }

  toggleEmptyState(show) {
    if (!this.hasEmptyStateTarget) return
    this.emptyStateTarget.hidden = !show
    if (show) {
      const slot = this.emptyStateTarget.querySelector("[data-search-empty-query]")
      if (slot) slot.textContent = this.queryValue
    }
  }

  announce(message) {
    if (!this.hasLiveRegionTarget) return
    this.liveRegionTarget.textContent = message
  }
}
