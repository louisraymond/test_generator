import { Controller } from "@hotwired/stimulus"

const STORAGE_PREFIX = 'topic-detail:topic-'
const STORAGE_SUFFIX = ':expanded'
const PULSE_MS       = 300

export default class extends Controller {
  static targets = ['toggle', 'body', 'chip', 'loRow']
  static values  = { id: Number, topicId: Number }

  connect() {
    this._mode = 'questions'
    this._restoreState()

    this._boundMode  = (e) => this._onModeChanged(e)
    this._boundFocus = (e) => this._onFocusLo(e)
    this._boundEx    = () => this._setExpanded(true)
    this._boundCol   = () => this._setExpanded(false)
    this._boundTog   = (e) => this._onTargettedToggle(e)

    window.addEventListener('topic-heatmap:mode-changed', this._boundMode)
    window.addEventListener('topic-heatmap:focus-lo',     this._boundFocus)
    window.addEventListener('topic-module:expand-all',    this._boundEx)
    window.addEventListener('topic-module:collapse-all',  this._boundCol)
    window.addEventListener('topic-module:toggle',        this._boundTog)
  }

  disconnect() {
    window.removeEventListener('topic-heatmap:mode-changed', this._boundMode)
    window.removeEventListener('topic-heatmap:focus-lo',     this._boundFocus)
    window.removeEventListener('topic-module:expand-all',    this._boundEx)
    window.removeEventListener('topic-module:collapse-all',  this._boundCol)
    window.removeEventListener('topic-module:toggle',        this._boundTog)
  }

  toggle(event) {
    if (event && event.target && event.target.closest && event.target.closest('.topic-module__edit')) return
    const expanded = this.toggleTarget.getAttribute('aria-expanded') === 'true'
    this._setExpanded(!expanded)
  }

  edit(event) {
    if (event) {
      event.stopPropagation()
      event.preventDefault()
    }
    // V1 stub: real edit ships in #58.
    const flash = new CustomEvent('topic-module:edit-not-implemented',
      { detail: { id: this.idValue, msg: 'Editing modules ships in #58.' } })
    window.dispatchEvent(flash)
  }

  // private

  _onTargettedToggle(event) {
    if (!event || !event.detail) return
    if (Number(event.detail.id) !== this.idValue) return
    const expanded = this.toggleTarget.getAttribute('aria-expanded') === 'true'
    this._setExpanded(!expanded)
  }

  _setExpanded(open) {
    this.toggleTarget.setAttribute('aria-expanded', String(open))
    if (open) {
      this.bodyTarget.removeAttribute('hidden')
      this.element.classList.remove('topic-module--collapsed')
    } else {
      this.bodyTarget.setAttribute('hidden', '')
      this.element.classList.add('topic-module--collapsed')
    }
    this._persist(open)
  }

  _persist(open) {
    try {
      const key = `${STORAGE_PREFIX}${this.topicIdValue}${STORAGE_SUFFIX}`
      const raw = window.localStorage.getItem(key)
      const arr = raw ? JSON.parse(raw) : []
      const set = new Set(arr)
      if (open) set.add(this.idValue); else set.delete(this.idValue)
      window.localStorage.setItem(key, JSON.stringify([...set]))
    } catch (_e) {
      // Safari private mode and similar — accept silently.
    }
  }

  _restoreState() {
    try {
      const key = `${STORAGE_PREFIX}${this.topicIdValue}${STORAGE_SUFFIX}`
      const raw = window.localStorage.getItem(key)
      if (!raw) return
      let arr
      try {
        arr = JSON.parse(raw)
      } catch (_e) {
        // Corrupt key — drop it and fall back to defaults.
        window.localStorage.removeItem(key)
        return
      }
      if (!Array.isArray(arr)) return
      const wasOpen = arr.includes(this.idValue)
      this._setExpanded(wasOpen)
    } catch (_e) {
      // localStorage unavailable.
    }
  }

  _onModeChanged(event) {
    if (!event || !event.detail) return
    this._mode = event.detail.mode === 'usage' || event.detail.mode === 'utilization'
      ? 'usage'
      : 'questions'
    if (this._raf) return
    this._raf = window.requestAnimationFrame(() => {
      this._raf = null
      this.chipTargets.forEach((chip) => this._repaintChip(chip))
    })
  }

  _repaintChip(chip) {
    const q = Number(chip.dataset.questions || 0)
    const u = Number(chip.dataset.usage || 0)
    const v = this._mode === 'usage' ? u : q
    chip.textContent = this._mode === 'usage' ? `${v}x` : `${v}q`
    chip.setAttribute('aria-label',
      `${v} ${this._mode === 'usage' ? 'exam uses' : 'questions'}`)
    chip.classList.remove(
      'topic-detail__chip--zero', 'topic-detail__chip--b1',
      'topic-detail__chip--b2',  'topic-detail__chip--b3',
      'topic-detail__chip--b4'
    )
    chip.classList.add(this._bucketClass(v))
  }

  _bucketClass(n) {
    if (n <= 0) return 'topic-detail__chip--zero'
    if (n === 1) return 'topic-detail__chip--b1'
    if (n <= 3)  return 'topic-detail__chip--b2'
    if (n <= 6)  return 'topic-detail__chip--b3'
    return 'topic-detail__chip--b4'
  }

  _onFocusLo(event) {
    if (!event || !event.detail) return
    const id = String(event.detail.loId)
    const row = this.loRowTargets.find((r) => r.dataset.loId === id)
    if (!row) return
    row.classList.add('topic-detail__lo--pulse')
    // Move keyboard focus to the row so screen readers announce the move.
    try { row.focus({ preventScroll: false }) } catch (_e) { /* ignore */ }
    window.setTimeout(() => row.classList.remove('topic-detail__lo--pulse'), PULSE_MS)
  }
}
