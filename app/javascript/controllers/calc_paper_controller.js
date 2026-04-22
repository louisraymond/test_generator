import PaperEditorController from "controllers/paper_editor_controller"

// Calculation paper-is-editor (Wave 3).
// The workbox and final-answer row are static on the paper; the interesting
// editing happens on the rail (units, tolerance, marking steps). This
// controller exists so the q.calculation element attaches the base paper-
// editor wiring (stem blur → autosave). No extra actions for now.
export default class extends PaperEditorController {}
