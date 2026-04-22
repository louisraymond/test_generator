import PaperEditorController from "controllers/paper_editor_controller"

// Composite paper-is-editor (Wave 3).
// Authors edit each sub-part's stem inline (base class). ⌥↵ on a part
// appends a new sub-part below; Tab/Shift-Tab nest/outdent.
export default class extends PaperEditorController {
  connect() {
    super.connect()
    this.element.addEventListener("keydown", this._onKey.bind(this))
  }

  async _onKey(event) {
    if (!event.altKey || event.key !== "Enter") return
    const target = event.target
    if (!target.matches("[data-edit]")) return
    event.preventDefault()
    await this._post(
      `/questions/${this.questionIdValue}/options_patch`,
      { options: { add_part: { after: target.closest(".composite__part")?.dataset.partIndex } } },
      "PATCH"
    )
    document.dispatchEvent(new CustomEvent("canvas:dirty"))
  }
}
