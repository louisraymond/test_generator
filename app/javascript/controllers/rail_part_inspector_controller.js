import { Controller } from "@hotwired/stimulus"

// Editor ticket #10 — rail-part-inspector controller.
//
// Listens for `composite:part-selected` window events emitted by the
// composite-editor controller (the paper-side selection gesture). When
// a part is selected, swap the rail's question-level chrome out and
// reveal the per-part inspector — type pills, marks input, answer_size
// select, and (where applicable) answer_label / unit fields.
//
// On user input we PATCH `/questions/:id/options_patch` with
// { options: { update_part: { index, <attr>: value } } } and dispatch
// `cm:dirty` / `cm:saved` events on the inspector element so the
// save-chrome controller's counter stays in sync.
//
// Type-switch (Flow A·04): clicking a different type pill does NOT
// PATCH straight away — instead it shows a yellow-banner warning. Only
// the Confirm button fires the PATCH. Cancel restores the active pill.
//
// Supported types (per #9's standalone-partial coverage). Cloze,
// diagram_label, image_occlusion intentionally omitted — they have no
// composite-part renderer in #9.
const SUPPORTED_TYPES = [
  "written",
  "multiple_choice",
  "calculation",
  "markdown",
  "matching",
  "ordering",
  "ranking",
  "code_analysis",
]

const ANSWER_SIZES = ["short", "medium", "long"]

export default class extends Controller {
  static targets = [
    "panel",
    "header",
    "pills",
    "typePill",
    "marks",
    "answerSize",
    "answerLabel",
    "unit",
    "warningBanner",
  ]
  static values = { questionId: Number }

  connect() {
    this._activeIndex = null
    this._activeType  = null
    this._pendingType = null

    this._onSelected = (e) => this._handleSelected(e.detail || {})
    window.addEventListener("composite:part-selected", this._onSelected)
  }

  disconnect() {
    window.removeEventListener("composite:part-selected", this._onSelected)
  }

  _handleSelected(detail) {
    const { partIndex, partType, partLetter, questionId } = detail
    if (questionId && this.hasQuestionIdValue && this.questionIdValue &&
        Number(questionId) !== Number(this.questionIdValue)) {
      return
    }

    this._activeIndex = Number(partIndex)
    this._activeType  = String(partType || "written")
    this._pendingType = null

    // Hide the question-level rail-typeblock for composite (the parts
    // count hint) so the rail focuses on this single part.
    this._toggleQuestionLevelChrome(false)

    // Read the live values from the paper DOM so the inspector reflects
    // any unsaved edits to the part's stem etc. We pull marks/size/etc.
    // off the paper's data-* attributes if present, otherwise fall back
    // to the source-of-truth render that the server sent on page load.
    const li = document.querySelector(`[data-part-index="${this._activeIndex}"]`)
    const marks       = li?.dataset.partMarks       || ""
    const answerSize  = li?.dataset.partAnswerSize  || ""
    const answerLabel = li?.dataset.partAnswerLabel || ""
    const unit        = li?.dataset.partUnit        || ""

    this._renderInspector({
      partLetter: partLetter || String.fromCharCode("a".charCodeAt(0) + this._activeIndex),
      partType:   this._activeType,
      marks,
      answerSize,
      answerLabel,
      unit,
    })

    if (this.hasPanelTarget) this.panelTarget.hidden = false
  }

  _toggleQuestionLevelChrome(show) {
    // The composite-question-level rail-typeblock is the .rail-typeblock
    // sibling rendered by `_rail_content.html.erb` — hide it when the
    // per-part inspector takes over, restore when nothing is selected.
    const root = document.querySelector('[data-rail-panel="content"]')
    if (!root) return
    const block = root.querySelector(".rail-typeblock")
    if (!block) return
    block.hidden = !show
  }

  _renderInspector({ partLetter, partType, marks, answerSize, answerLabel, unit }) {
    if (!this.hasPanelTarget) return

    if (this.hasHeaderTarget) {
      this.headerTarget.textContent = `part (${partLetter}) · ${partType}`
    }

    // Active-pill styling.
    if (this.hasTypePillTarget) {
      this.typePillTargets.forEach(pill => {
        pill.classList.toggle("is-active", pill.dataset.partTypePill === partType)
      })
    }

    if (this.hasMarksTarget && marks !== undefined) {
      this.marksTarget.value = marks || ""
    }
    if (this.hasAnswerSizeTarget) {
      this.answerSizeTarget.value = answerSize || "medium"
    }
    if (this.hasAnswerLabelTarget) {
      this.answerLabelTarget.value = answerLabel || ""
    }
    if (this.hasUnitTarget) {
      this.unitTarget.value = unit || ""
    }

    // Hide warning banner on every fresh selection.
    if (this.hasWarningBannerTarget) this.warningBannerTarget.hidden = true
  }

  // Stimulus action — click on a type pill.
  pickType(event) {
    if (this._activeIndex == null) return
    const pill = event.currentTarget
    const newType = pill.dataset.partTypePill
    if (!newType || !SUPPORTED_TYPES.includes(newType)) return

    if (newType === this._activeType) return  // no-op

    // Show the yellow-banner warning and stash the pending type.
    this._pendingType = newType
    if (this.hasWarningBannerTarget) this.warningBannerTarget.hidden = false
  }

  // Stimulus action — Confirm in the warning banner.
  async confirmTypeSwitch(event) {
    if (event) event.preventDefault()
    if (!this._pendingType) return
    if (this._activeIndex == null) return

    const newType = this._pendingType
    await this._patchPart({ type: newType })

    this._activeType = newType
    this._pendingType = null

    // Update active pill + header.
    if (this.hasTypePillTarget) {
      this.typePillTargets.forEach(pill => {
        pill.classList.toggle("is-active", pill.dataset.partTypePill === newType)
      })
    }
    if (this.hasHeaderTarget) {
      const letter = String.fromCharCode("a".charCodeAt(0) + this._activeIndex)
      this.headerTarget.textContent = `part (${letter}) · ${newType}`
    }

    if (this.hasWarningBannerTarget) this.warningBannerTarget.hidden = true
  }

  // Stimulus action — Cancel in the warning banner.
  cancelTypeSwitch(event) {
    if (event) event.preventDefault()
    this._pendingType = null
    if (this.hasWarningBannerTarget) this.warningBannerTarget.hidden = true
  }

  // Stimulus action — change on marks <input>.
  marksChanged(event) {
    if (this._activeIndex == null) return
    const value = Number(event.currentTarget.value)
    if (Number.isNaN(value)) return
    this._patchPart({ marks: value })
  }

  // Stimulus action — change on answer_size <select>.
  answerSizeChanged(event) {
    if (this._activeIndex == null) return
    const value = String(event.currentTarget.value || "")
    if (!ANSWER_SIZES.includes(value)) return
    this._patchPart({ answer_size: value })
  }

  // Stimulus action — change on answer_label <input>.
  answerLabelChanged(event) {
    if (this._activeIndex == null) return
    this._patchPart({ answer_label: String(event.currentTarget.value || "") })
  }

  // Stimulus action — change on unit <input>.
  unitChanged(event) {
    if (this._activeIndex == null) return
    this._patchPart({ unit: String(event.currentTarget.value || "") })
  }

  async _patchPart(attrs) {
    const idx = this._activeIndex
    if (idx == null) return

    // Mark dirty in the chrome up-front so the Save indicator reflects
    // pending state even before the network round-trip resolves.
    this.element.dispatchEvent(new CustomEvent("cm:dirty", {
      bubbles: true,
      detail: { dirty: true, fieldId: `part-${idx}` },
    }))

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const body = {
      options: { update_part: Object.assign({ index: idx }, attrs) },
    }

    let res
    try {
      res = await fetch(`/questions/${this.questionIdValue}/options_patch`, {
        method:  "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": token || "",
          "Accept":       "text/html",
        },
        body: JSON.stringify(body),
      })
    } catch (_e) {
      return
    }
    if (!res || !res.ok) return

    // If the server returned the re-rendered composite root, swap it in
    // so the paper morphs in place (Flow A·04 — type switch causes the
    // answer surface to morph, e.g. `written` → `multiple_choice`).
    const html = await res.text()
    if (html && html.length) {
      const wrapper = document.createElement("div")
      wrapper.innerHTML = html
      const fresh = wrapper.querySelector("[data-composite-root]")
      const root  = document.querySelector("[data-composite-root]")
      if (root && fresh) {
        root.replaceWith(fresh)
        // Re-apply the is-selected highlight on the morphed-in part.
        const li = document.querySelector(`[data-part-index="${idx}"]`)
        if (li) li.classList.add("is-selected")
      }
    }

    // Saved.
    this.element.dispatchEvent(new CustomEvent("cm:saved", {
      bubbles: true,
      detail: { fieldId: `part-${idx}` },
    }))
  }
}
