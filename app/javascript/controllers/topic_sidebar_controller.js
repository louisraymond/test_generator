import { Controller } from "@hotwired/stimulus"

// sub-53 — Topic Detail v2 sidebar controller.  Single-responsibility:
// scroll-spy + active-state + click-to-scroll for the 300px sidebar.
// Form/CRUD logic lives in topic_detail_controller.js; do not merge them.
//
// Connects to data-controller="topic-sidebar"
export default class extends Controller {
  static targets = ["entry", "viewPill", "switcher"]
  static values = { topicId: Number }

  connect() {
    this.observer = new IntersectionObserver(this.onIntersect.bind(this), {
      root: null,
      rootMargin: "-30% 0px -60% 0px",
      threshold: 0,
    })
    document.querySelectorAll("[id^='mod-']").forEach((el) => this.observer.observe(el))
  }

  disconnect() {
    this.observer?.disconnect()
  }

  // Click handler for sidebar links: prevents the default hash jump,
  // sets the active link, smooth-scrolls the target into view, and
  // shifts focus to the destination heading for keyboard users.
  activate(event) {
    event.preventDefault()
    const link = event.currentTarget
    const id = link.dataset.moduleId
    const target = document.getElementById(`mod-${id}`)
    if (!target) return

    this.setActive(link)
    target.scrollIntoView({ behavior: "smooth", block: "start" })
    const heading = target.querySelector("h2,h3")
    heading?.focus({ preventScroll: true })
  }

  // IntersectionObserver callback.  Picks the topmost visible module and
  // promotes its sidebar entry to aria-current="location" so the active
  // state tracks scroll position.
  onIntersect(entries) {
    const visible = entries
      .filter((e) => e.isIntersecting)
      .sort((a, b) => a.target.offsetTop - b.target.offsetTop)[0]
    if (!visible) return
    const id = visible.target.id.replace("mod-", "")
    const link = this.entryTargets.find((e) => e.dataset.moduleId === id)
    if (link) this.setActive(link)
  }

  setActive(link) {
    this.entryTargets.forEach((e) => e.removeAttribute("aria-current"))
    link.setAttribute("aria-current", "location")
  }
}
