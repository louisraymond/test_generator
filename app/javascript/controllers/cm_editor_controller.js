import { Controller } from "@hotwired/stimulus"

// CM6 + extensions are imported lazily inside connect() so the controller file
// itself is small and the heavy bundle only loads when an editor mounts.
export default class extends Controller {
  static values = {
    source:     String,
    saveUrl:    String,
    saveField:  String,        // e.g. "question[content]" or JSON path for options_patch
    questionId: Number,
    debounceMs: { type: Number, default: 400 },
  }

  async connect() {
    const [
      { EditorState },
      { EditorView, keymap, lineNumbers },
      { defaultKeymap, history, historyKeymap },
      { markdown }
    ] = await Promise.all([
      import("@codemirror/state"),
      import("@codemirror/view"),
      import("@codemirror/commands"),
      import("@codemirror/lang-markdown"),
    ])

    this._save = this._debounce(this._flushSave.bind(this), this.debounceMsValue)

    this.view = new EditorView({
      state: EditorState.create({
        doc: this.sourceValue || "",
        extensions: [
          history(),
          keymap.of([...defaultKeymap, ...historyKeymap]),
          markdown(),
          EditorView.updateListener.of(u => {
            if (u.docChanged) this._save()
          }),
          EditorView.domEventHandlers({
            blur: () => this._flushSave(),
          }),
        ],
      }),
      parent: this.element,
    })

    this.element.cmView = this.view  // for test introspection
    this.element.dispatchEvent(new CustomEvent("cm:ready", { bubbles: true }))

    // Flush on tab close / navigation. pagehide fires more reliably than
    // beforeunload and supports keepalive: true fetches.
    this._onPageHide = () => this._flushSave({ keepalive: true })
    window.addEventListener("pagehide", this._onPageHide)
  }

  disconnect() {
    window.removeEventListener("pagehide", this._onPageHide)
    if (this.view) {
      this.view.destroy()
      this.view = null
    }
  }

  async _flushSave(opts = {}) {
    if (!this.view) return
    const value = this.view.state.doc.toString()
    if (value === this._lastSaved) return
    this._lastSaved = value

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const body = this._buildBody(value)

    await fetch(this.saveUrlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token || "",
        "Accept":       "application/json",
      },
      body: JSON.stringify(body),
      keepalive: !!opts.keepalive,
    })

    // Stamp for tests + autosave UI hooks.
    this.element.dataset.cmSavedAt = String(Date.now())
    this.element.dispatchEvent(new CustomEvent("cm:saved", { bubbles: true }))
  }

  // saveField follows one of two shapes:
  //   - "question[content]"                      → top-level Rails form pattern
  //   - "options_patch:update_part:<index>:stem" → routed to options_patch controller
  _buildBody(value) {
    const f = this.saveFieldValue
    if (f.startsWith("options_patch:")) {
      const [, command, index, attr] = f.split(":")
      return { options: { [command]: { index: Number(index), [attr]: value } } }
    }
    // question[content] → { question: { content: value } }
    const m = f.match(/^(\w+)\[(\w+)\]$/)
    if (!m) throw new Error(`cm-editor: unknown saveField shape: ${f}`)
    return { [m[1]]: { [m[2]]: value } }
  }

  _debounce(fn, ms) {
    let t = null
    return (...args) => {
      clearTimeout(t)
      t = setTimeout(() => fn.apply(this, args), ms)
    }
  }
}
