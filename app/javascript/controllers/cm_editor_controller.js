import { Controller } from "@hotwired/stimulus"

// CM6 + extensions are imported lazily inside connect() so the controller file
// itself is small and the heavy bundle only loads when an editor mounts.
//
// Save semantics (Editor ticket #40, design contract item 4):
//   - NO autosave on docChanged.
//   - NO blur flush.
//   - NO pagehide / beforeunload flush — tab close means data loss, by design.
//   - The controller exposes `save()`. The page chrome's Save button calls it.
//   - On every doc change we set `_dirty = true` and dispatch `cm:dirty`
//     ({ detail: { dirty, fieldId } }) so chrome can render the indicator.
//   - On a successful POST we set `_dirty = false`, stamp data-cm-saved-at,
//     and dispatch `cm:saved`.
export default class extends Controller {
  static values = {
    source:     String,
    saveUrl:    String,
    saveField:  String,        // e.g. "question[content]" or JSON path for options_patch
    questionId: Number,
  }

  async connect() {
    const [
      { EditorState },
      { EditorView, keymap, lineNumbers },
      { defaultKeymap, history, historyKeymap },
      { markdown },
      { markdownPreview }
    ] = await Promise.all([
      import("@codemirror/state"),
      import("@codemirror/view"),
      import("@codemirror/commands"),
      import("@codemirror/lang-markdown"),
      import("lib/cm_markdown_preview"),
    ])

    this._dirty = false

    this.view = new EditorView({
      state: EditorState.create({
        doc: this.sourceValue || "",
        extensions: [
          history(),
          keymap.of([...defaultKeymap, ...historyKeymap]),
          markdown(),
          markdownPreview,
          // Track dirty state only — no autosave, no debounced POST.
          EditorView.updateListener.of(u => {
            if (u.docChanged) this._markDirty()
          }),
        ],
      }),
      parent: this.element,
    })

    this.element.cmView = this.view  // for test introspection
    this.element.dispatchEvent(new CustomEvent("cm:ready", { bubbles: true }))
  }

  disconnect() {
    if (this.view) {
      this.view.destroy()
      this.view = null
    }
  }

  // Public API. The page chrome's Save button calls this on every mounted
  // cm-editor element. Idempotent: a no-op if !this._dirty.
  async save() {
    if (!this.view) return
    if (!this._dirty) return
    await this._flushSave()
  }

  _markDirty() {
    if (this._dirty) return
    this._dirty = true
    this.element.dispatchEvent(new CustomEvent("cm:dirty", {
      bubbles: true,
      detail: { dirty: true, fieldId: this.saveFieldValue },
    }))
  }

  async _flushSave() {
    const value = this.view.state.doc.toString()

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
    })

    this._dirty = false
    this.element.dataset.cmSavedAt = String(Date.now())
    this.element.dispatchEvent(new CustomEvent("cm:saved", {
      bubbles: true,
      detail: { fieldId: this.saveFieldValue },
    }))
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
}
