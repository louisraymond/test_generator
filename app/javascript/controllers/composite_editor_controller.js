import { Controller } from "@hotwired/stimulus"

// Editor ticket #39 — composite-editor controller manages the parts list:
//   addAfter — POSTs `add_part` and swaps in the re-rendered composite root.
//
// Editor ticket #10 — extends the controller to track which part is
// currently selected. Clicking anywhere inside a part's <li> sets the
// `is-selected` class on that <li>, clears it from siblings, and
// dispatches a `composite:part-selected` window event with detail
// { questionId, partIndex, partType, partLetter } so the rail's
// rail-part-inspector controller can swap the Content panel.
//
// Clicks that originate inside a CM6 editor are ignored — those should
// keep focus on the editor and not double as a part-select gesture.
export default class extends Controller {
  static values = { questionId: Number }

  // Stimulus action: click->composite-editor#select on each <li data-part-index>.
  select(event) {
    // Ignore clicks landing inside any cm-editor — the editor handles its
    // own focus and we don't want a select gesture to fight with caret
    // placement. Buttons (e.g. add-part-below) also bypass selection.
    if (event.target.closest('[data-controller~="cm-editor"]')) return
    if (event.target.closest('button'))                        return

    const li = event.currentTarget
    if (!li || li.dataset.partIndex == null) return

    const root = this.element
    root.querySelectorAll("li[data-part-index].is-selected").forEach(el => {
      if (el !== li) el.classList.remove("is-selected")
    })
    li.classList.add("is-selected")

    const partIndex = Number(li.dataset.partIndex)
    const partType  = li.dataset.partType || ""
    const partLetter = String.fromCharCode("a".charCodeAt(0) + partIndex)

    window.dispatchEvent(new CustomEvent("composite:part-selected", {
      detail: {
        questionId: this.questionIdValue,
        partIndex,
        partType,
        partLetter,
      },
    }))
  }

  async addAfter(event) {
    const partEl = event.target.closest("[data-part-index]")
    const after  = Number(partEl.dataset.partIndex)
    const token  = document.querySelector('meta[name="csrf-token"]')?.content

    const res = await fetch(`/questions/${this.questionIdValue}/options_patch`, {
      method:  "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token || "",
        "Accept":       "text/html",   // server returns the re-rendered composite block
      },
      body: JSON.stringify({ options: { add_part: { after } } }),
    })
    if (!res.ok) return

    // Server returns the freshly-rendered composite root. Replace the existing
    // <ol data-composite-root>; Stimulus will auto-connect new cm-editor
    // controllers on the new <li> elements.
    const html = await res.text()
    const root = document.querySelector("[data-composite-root]")
    const wrapper = document.createElement("div")
    wrapper.innerHTML = html
    const fresh = wrapper.querySelector("[data-composite-root]")
    if (root && fresh) root.replaceWith(fresh)
  }
}
