import PaperEditorController from "controllers/paper_editor_controller"

// Matching paper-is-editor (Wave 3).
// Inline text edit on left + right columns is handled by the base class via
// [data-edit]. This subclass adds the `Re-seed` hook used by the rail to
// reshuffle the right column on print without changing the pairs.
export default class extends PaperEditorController {
  static targets = ["row"]

  async reseed() {
    const seed = Math.floor(Math.random() * 99999)
    await this._post(
      `/questions/${this.questionIdValue}/options_patch`,
      { options: { seed } },
      "PATCH"
    )
  }
}
