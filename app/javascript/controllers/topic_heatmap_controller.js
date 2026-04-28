import { Controller } from "@hotwired/stimulus"

const HEAT_CLASSES = [
  'topic-heatmap__cell--heat-0',
  'topic-heatmap__cell--heat-1',
  'topic-heatmap__cell--heat-2',
  'topic-heatmap__cell--heat-3',
  'topic-heatmap__cell--heat-4'
]

const CLAMP = 99

// Topic heat-map (sub-54).
//
// Owns the only JS surface for the topic-heatmap block:
//   - Mode swap between "coverage" and "utilization" (data-mode attribute).
//   - Per-cell class + textContent rewrite (bucket can differ between modes).
//   - Custom-event dispatch:
//       * topic-heatmap:mode-changed (detail = { mode })
//       * topic-heatmap:focus-lo    (detail = { loId })
//
// All DOM writes happen inside one requestAnimationFrame on mode change to
// avoid layout thrash (see plan §4 Persona C).
export default class extends Controller {
  static values = { mode: { type: String, default: 'coverage' } }
  static targets = ['title', 'summary', 'cell', 'legendCaption', 'tab']

  connect() {
    // Apply initial state (idempotent — partial pre-renders the right classes,
    // but this guards against drift when sub-53 wires a non-coverage default).
    this._applyMode(this.modeValue, { silent: true })
  }

  selectMode(event) {
    const next = event.params.mode
    if (next === this.modeValue) return
    this.modeValue = next
  }

  modeValueChanged(value, previous) {
    if (previous === undefined) return // initial connect handles this
    this._applyMode(value, { silent: false })
  }

  focusOutcome(event) {
    const cell = event.target.closest('[data-cell-lo-id]')
    if (!cell) return
    const loId = Number(cell.dataset.cellLoId)
    this.dispatch('focus-lo', { detail: { loId }, bubbles: true })
  }

  _applyMode(mode, { silent }) {
    requestAnimationFrame(() => {
      this.element.dataset.mode = mode

      this.tabTargets.forEach((tab) => {
        const isActive = tab.dataset.topicHeatmapModeParam === mode
        tab.setAttribute('aria-selected', isActive ? 'true' : 'false')
        tab.tabIndex = isActive ? 0 : -1
      })

      this.cellTargets.forEach((cell) => {
        const cov = Number(cell.dataset.coverageCount)
        const util = Number(cell.dataset.utilizationCount)
        const n = mode === 'utilization' ? util : cov
        const bucket = mode === 'utilization'
          ? Number(cell.dataset.utilizationBucket)
          : Number(cell.dataset.coverageBucket)

        cell.classList.remove(...HEAT_CLASSES)
        cell.classList.add(HEAT_CLASSES[bucket] || HEAT_CLASSES[0])
        cell.textContent = n > CLAMP ? `${CLAMP}+` : String(n)

        // Refresh aria-label / title to match the active mode's count + units.
        const lo = cell.dataset.loCategory && cell.dataset.loDescription
          ? `${cell.dataset.loCategory} — ${cell.dataset.loDescription}`
          : null
        if (lo) {
          const units = mode === 'utilization' ? 'exam uses' : 'questions'
          const label = `${lo}, ${n} ${units}`
          cell.setAttribute('aria-label', label)
          cell.setAttribute('title', label)
        }
      })

      if (!silent) {
        this.dispatch('mode-changed', { detail: { mode }, bubbles: true })
      }
    })
  }
}
