import { Controller } from "@hotwired/stimulus"

// ⌘K command palette (Wave 5.4).
// Global keyboard shortcut opens a fuzzy-searchable action list.
// Each action has:
//   - label (what the user types / sees)
//   - hint  (secondary caption, e.g. "Navigate · Workspace")
//   - url   (Turbo-friendly path to visit)
//   - group (used for grouping in the list)
//   - shortcut (optional, displayed on the right)
//
// Actions are declared on the .app element via data attributes from the
// server so the registry stays in one place. Example:
//   data-palette-actions-value='[{"label":"Dashboard",...}]'
//
// If no actions are declared we fall back to a static default set
// (navigation + common create actions).
export default class extends Controller {
  static values = { actions: Array }

  connect() {
    this._onKey = this._onKey.bind(this)
    document.addEventListener("keydown", this._onKey)
    this._buildPalette()
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKey)
    this._removePalette()
  }

  _onKey(event) {
    const isMod = event.metaKey || event.ctrlKey
    if (isMod && event.key.toLowerCase() === "k") {
      event.preventDefault()
      this.open()
    } else if (event.key === "Escape" && this.isOpen) {
      event.preventDefault()
      this.close()
    }
  }

  open() {
    if (!this.root) return
    this.isOpen = true
    this.root.classList.add("is-open")
    this.root.querySelector(".palette__input").focus()
    this._render("")
  }

  close() {
    if (!this.root) return
    this.isOpen = false
    this.root.classList.remove("is-open")
  }

  _actions() {
    if (this.actionsValue && this.actionsValue.length > 0) return this.actionsValue
    return [
      { label: "Dashboard",          hint: "Workspace",       url: "/workspace?tab=dashboard",     group: "Navigate" },
      { label: "Canvas",             hint: "Edit · current exam", url: "/workspace?tab=canvas",     group: "Navigate" },
      { label: "Topics",             hint: "Library",         url: "/workspace?tab=topics",        group: "Navigate" },
      { label: "Question bank",      hint: "Library",         url: "/workspace?tab=questions",     group: "Navigate" },
      { label: "Knowledge base",     hint: "Library",         url: "/workspace?tab=kb",            group: "Navigate" },
      { label: "Templates",          hint: "Build",           url: "/workspace?tab=templates",     group: "Navigate" },
      { label: "Generate exam",      hint: "Build · 3-step wizard", url: "/workspace?tab=generate", group: "Navigate", shortcut: "G N" },
      { label: "Exam history",       hint: "History",         url: "/workspace?tab=history",       group: "Navigate" },
      { label: "Review & Export",    hint: "Edit",            url: "/workspace?tab=review",        group: "Navigate" },

      { label: "New question",       hint: "Open the question editor",     url: "/questions/new",   group: "Create" },
      { label: "New template",       hint: "Open the template form",       url: "/exam_templates/new", group: "Create" },
      { label: "New topic",          hint: "Open the topic form",          url: "/topics/new",      group: "Create" },

      { label: "Classic UI",         hint: "Switch to the hamburger chrome for one page", url: "/workspace?ui=classic", group: "Other" },
      { label: "API docs",           hint: "OpenAPI reference (new tab)",  url: "/api/docs.html",   group: "Other", external: true }
    ]
  }

  _buildPalette() {
    const existing = document.getElementById("palette-root")
    if (existing) { this.root = existing; return }
    const root = document.createElement("div")
    root.id = "palette-root"
    root.className = "palette"
    root.innerHTML = `
      <div class="palette__backdrop" data-palette-dismiss></div>
      <div class="palette__panel" role="dialog" aria-label="Command palette">
        <div class="palette__inputwrap">
          <span class="palette__kbd">⌘K</span>
          <input class="palette__input" type="text" autocomplete="off"
                 placeholder="Type a command or search…" aria-label="Command palette search">
        </div>
        <div class="palette__results" role="listbox"></div>
        <footer class="palette__footer">
          <span class="palette__footer-k">↵ open · esc close · ↑↓ move</span>
        </footer>
      </div>`
    document.body.appendChild(root)
    this.root = root

    root.querySelector("[data-palette-dismiss]").addEventListener("click", () => this.close())
    const input = root.querySelector(".palette__input")
    input.addEventListener("input", (e) => this._render(e.target.value))
    input.addEventListener("keydown", (e) => this._handleNav(e))
  }

  _removePalette() {
    if (this.root && this.root.parentNode) this.root.parentNode.removeChild(this.root)
    this.root = null
  }

  _render(query) {
    const q = query.trim().toLowerCase()
    const all = this._actions()
    const filtered = q
      ? all.filter(a => (a.label + " " + (a.hint || "")).toLowerCase().includes(q))
      : all

    const grouped = {}
    filtered.forEach(a => {
      const g = a.group || "Actions"
      grouped[g] = grouped[g] || []
      grouped[g].push(a)
    })

    const results = this.root.querySelector(".palette__results")
    results.innerHTML = ""
    if (filtered.length === 0) {
      results.innerHTML = `<div class="palette__empty">No matches.</div>`
      return
    }

    Object.entries(grouped).forEach(([group, actions]) => {
      const section = document.createElement("div")
      section.className = "palette__group"
      section.innerHTML = `<div class="palette__group-label">${group}</div>`
      actions.forEach((a, i) => {
        const item = document.createElement("button")
        item.className = "palette__item"
        item.type = "button"
        item.innerHTML = `
          <span class="palette__item-label">${a.label}</span>
          ${a.hint ? `<span class="palette__item-hint">${a.hint}</span>` : ""}
          ${a.shortcut ? `<span class="palette__item-k">${a.shortcut}</span>` : ""}`
        item.addEventListener("click", () => this._activate(a))
        section.appendChild(item)
      })
      results.appendChild(section)
    })

    // Highlight first result
    const first = results.querySelector(".palette__item")
    if (first) first.classList.add("is-focused")
  }

  _handleNav(e) {
    const items = Array.from(this.root.querySelectorAll(".palette__item"))
    const current = items.findIndex(el => el.classList.contains("is-focused"))
    if (e.key === "ArrowDown") {
      e.preventDefault()
      if (items[current]) items[current].classList.remove("is-focused")
      const next = items[(current + 1) % items.length]
      if (next) { next.classList.add("is-focused"); next.scrollIntoView({ block: "nearest" }) }
    } else if (e.key === "ArrowUp") {
      e.preventDefault()
      if (items[current]) items[current].classList.remove("is-focused")
      const prev = items[(current - 1 + items.length) % items.length]
      if (prev) { prev.classList.add("is-focused"); prev.scrollIntoView({ block: "nearest" }) }
    } else if (e.key === "Enter") {
      e.preventDefault()
      const focused = items[current] || items[0]
      if (focused) focused.click()
    }
  }

  _activate(action) {
    this.close()
    if (!action.url) return
    if (action.external) {
      window.open(action.url, "_blank")
    } else {
      window.location.href = action.url
    }
  }
}
