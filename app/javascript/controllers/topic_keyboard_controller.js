import { Controller } from "@hotwired/stimulus"

const G_WINDOW_MS = 400
const TOAST_KEY = "topic-detail:keyboard-toast-seen"
const TOAST_DURATION_MS = 5000
const HOVER_DEBOUNCE_MS = 50
const INPUT_TAGS = ["INPUT", "TEXTAREA", "SELECT"]

// Connects to data-controller="topic-keyboard"
export default class extends Controller {
  static targets = ["overlay", "overlayClose", "toast", "ariaLive"]
  static values = {
    activeModuleIndex: { type: Number, default: 0 },
    moduleCount: { type: Number, default: 0 },
    lastHoveredLoId: { type: Number, default: 0 }
  }

  connect() {
    this.lastG = 0
    this.hoverTimer = null
    this.previouslyFocused = null
    this.overlayOpen = false
    this.toastTimer = null

    this.boundKeydown = this.handleKeydown.bind(this)
    this.boundPointerOver = this.handlePointerOver.bind(this)
    this.boundPointerLeave = this.handlePointerLeave.bind(this)
    this.boundFocusIn = this.handleFocusIn.bind(this)

    window.addEventListener("keydown", this.boundKeydown)
    document.addEventListener("pointerover", this.boundPointerOver)
    document.addEventListener("pointerout", this.boundPointerLeave)
    document.addEventListener("focusin", this.boundFocusIn)

    this.maybeShowFirstVisitToast()
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundKeydown)
    document.removeEventListener("pointerover", this.boundPointerOver)
    document.removeEventListener("pointerout", this.boundPointerLeave)
    document.removeEventListener("focusin", this.boundFocusIn)
    clearTimeout(this.hoverTimer)
    clearTimeout(this.toastTimer)
    if (this.overlayOpen) {
      // Tidy up body overflow if Turbo navigates away mid-overlay
      document.body.style.overflow = ""
      this.overlayOpen = false
    }
  }

  // ──────────── Main keydown router ────────────
  handleKeydown(event) {
    if (this.overlayOpen) return this.handleOverlayKeydown(event)

    const t = event.target
    const inEditable =
      INPUT_TAGS.includes(t.tagName) || (t.isContentEditable === true)

    if (inEditable) {
      // Esc inside input → blur, then stop
      if (event.key === "Escape") {
        event.preventDefault()
        t.blur()
      }
      return
    }

    // Modifier-key short-circuit. `?` is shift+/ which is allowed
    // (shift is the only allowed modifier).
    if (event.metaKey || event.ctrlKey || event.altKey) return

    // Any non-`g` key resets the g-g state machine.
    if (event.key !== "g") this.lastG = 0

    switch (event.key) {
      case "j": return this.advanceModule(+1, event)
      case "k": return this.advanceModule(-1, event)
      case " ": {
        // Space short-circuits when target is a button (else click + toggle both fire)
        if (t.tagName === "BUTTON" || t.getAttribute?.("role") === "button") return
        event.preventDefault()
        return this.dispatchModule("toggle")
      }
      case "o":
        event.preventDefault()
        return this.dispatch("topic-module:expand-all", { prefix: false })
      case "c":
        event.preventDefault()
        return this.dispatch("topic-module:collapse-all", { prefix: false })
      case "/":
        event.preventDefault()
        return this.dispatch("topic-search:focus", { prefix: false })
      case "?":
        event.preventDefault()
        return this.openOverlay()
      case "v":
        event.preventDefault()
        return this.dispatch("topic-view:cycle", { prefix: false })
      case "h":
        event.preventDefault()
        return this.dispatch("topic-heatmap:toggle-mode", { prefix: false })
      case "e":
        event.preventDefault()
        return this.openEditForActiveModule()
      case "n":
        event.preventDefault()
        return this.dispatch("topic-module:new-form-focus", { prefix: false })
      case "a":
        event.preventDefault()
        return this.dispatch("topic-module:add-outcome-active", {
          prefix: false,
          detail: { moduleIndex: this.activeModuleIndexValue }
        })
      case "q":
        event.preventDefault()
        return this.openQuestionForHoveredOutcome()
      case "g":
        return this.handleG(event)
      case "Escape":
        return // nothing to close at top level
    }

    // Number keys 1..9
    if (/^[1-9]$/.test(event.key)) {
      const n = parseInt(event.key, 10)
      if (n <= this.moduleCountValue) {
        event.preventDefault()
        this.dispatch("topic-sidebar:select-module", {
          prefix: false,
          detail: { index: n - 1 }
        })
      }
    }
  }

  // ──────────── g g state machine ────────────
  handleG(event) {
    const now = (typeof performance !== "undefined" && performance.now)
      ? performance.now()
      : Date.now()
    if (this.lastG > 0 && now - this.lastG < G_WINDOW_MS) {
      this.lastG = 0
      event.preventDefault()
      this.dispatch("topic-detail:scroll-top", { prefix: false })
    } else {
      this.lastG = now
    }
  }

  // ──────────── Active module pointer ────────────
  advanceModule(delta, event) {
    if (this.moduleCountValue <= 0) {
      event.preventDefault()
      return
    }
    const next = Math.min(
      Math.max(0, (this.activeModuleIndexValue || 0) + delta),
      this.moduleCountValue - 1
    )
    event.preventDefault()
    this.activeModuleIndexValue = next
    this.dispatch("topic-sidebar:select-module", {
      prefix: false,
      detail: { index: next }
    })
  }

  dispatchModule(action) {
    this.dispatch(`topic-module:${action}`, {
      prefix: false,
      detail: { index: this.activeModuleIndexValue }
    })
  }

  // ──────────── q : hover/focus → new question ────────────
  openQuestionForHoveredOutcome() {
    const hovered = document.querySelector(".lo-item:hover, .topic-module__lo:hover")
    const focused = document.activeElement?.closest?.(".lo-item, .topic-module__lo")
    const target = hovered || focused
    const loId = target?.dataset?.loId || (this.lastHoveredLoIdValue > 0 ? String(this.lastHoveredLoIdValue) : null)
    if (!loId) return this.announce("Hover an outcome first")
    const url = `/learning_objectives/${loId}/questions/new`
    if (window.Turbo && typeof window.Turbo.visit === "function") {
      window.Turbo.visit(url)
    } else {
      window.location.href = url
    }
  }

  // ──────────── e : edit active module (route gap, see plan §6) ────────────
  openEditForActiveModule() {
    this.announce("Edit not yet wired — coming soon")
  }

  // ──────────── Hover/focus tracking for q ────────────
  handlePointerOver(event) {
    const lo = event.target.closest?.(".lo-item, .topic-module__lo")
    if (!lo) return
    clearTimeout(this.hoverTimer)
    this.hoverTimer = setTimeout(() => {
      const id = parseInt(lo.dataset.loId, 10)
      if (!Number.isNaN(id)) this.lastHoveredLoIdValue = id
    }, HOVER_DEBOUNCE_MS)
  }

  handlePointerLeave() {
    clearTimeout(this.hoverTimer)
  }

  handleFocusIn(event) {
    // Reset g-state machine if focus enters an editable
    const t = event.target
    if (INPUT_TAGS.includes(t.tagName) || t.isContentEditable === true) {
      this.lastG = 0
    }
    const lo = t.closest?.(".lo-item, .topic-module__lo")
    if (lo) {
      const id = parseInt(lo.dataset.loId, 10)
      if (!Number.isNaN(id)) this.lastHoveredLoIdValue = id
    }
  }

  // ──────────── Overlay ────────────
  openOverlay() {
    if (this.overlayOpen) return
    if (!this.hasOverlayTarget) return
    this.previouslyFocused = document.activeElement
    this.overlayTarget.setAttribute("aria-hidden", "false")
    document.body.style.overflow = "hidden"
    this.overlayOpen = true
    this.dismissToast() // opening overlay implicitly acknowledges discoverability
    if (this.hasOverlayCloseTarget) this.overlayCloseTarget.focus()
  }

  closeOverlay() {
    if (!this.overlayOpen) return
    if (this.hasOverlayTarget) {
      this.overlayTarget.setAttribute("aria-hidden", "true")
    }
    document.body.style.overflow = ""
    this.overlayOpen = false
    const prev = this.previouslyFocused
    this.previouslyFocused = null
    if (prev && typeof prev.focus === "function") prev.focus()
  }

  backdropClose(event) {
    // Only close when click is on the overlay surface itself (not a child)
    if (event.target === this.overlayTarget) this.closeOverlay()
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  handleOverlayKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      return this.closeOverlay()
    }
    if (event.key === "Tab") return this.trapFocus(event)
    // Suppress every other shortcut while overlay is open — overlay is exclusive.
    // Allow Enter/Space so the close button still activates.
    if (event.key !== "Enter" && event.key !== " ") event.preventDefault()
  }

  trapFocus(event) {
    if (!this.hasOverlayTarget) return
    const focusable = this.overlayTarget.querySelectorAll(
      'button, [href], input, [tabindex]:not([tabindex="-1"])'
    )
    if (focusable.length === 0) return
    const first = focusable[0]
    const last = focusable[focusable.length - 1]
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }

  // ──────────── First-visit toast ────────────
  maybeShowFirstVisitToast() {
    if (!this.hasToastTarget) return
    let seen = null
    try { seen = localStorage.getItem(TOAST_KEY) } catch (_) { /* private mode */ }
    if (seen === "true") return
    this.toastTarget.removeAttribute("hidden")
    this.toastTimer = setTimeout(() => this.dismissToast(), TOAST_DURATION_MS)
  }

  dismissToast() {
    if (!this.hasToastTarget) return
    if (this.toastTarget.hasAttribute("hidden")) return
    this.toastTarget.setAttribute("hidden", "")
    clearTimeout(this.toastTimer)
    try { localStorage.setItem(TOAST_KEY, "true") } catch (_) { /* private mode */ }
  }

  // ──────────── aria-live announcer ────────────
  announce(msg) {
    if (!this.hasAriaLiveTarget) return
    this.ariaLiveTarget.textContent = ""
    setTimeout(() => { this.ariaLiveTarget.textContent = msg }, 50)
  }
}
