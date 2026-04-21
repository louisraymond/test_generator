import { Controller } from "@hotwired/stimulus"

// KB upload affordance (Phase 8 stub).
// Adds drag-hover class; Phase 8.5 wires ActiveStorage direct upload.
export default class extends Controller {
  connect() {
    this.element.addEventListener("dragover", this.onDragOver)
    this.element.addEventListener("dragleave", this.onDragLeave)
    this.element.addEventListener("drop", this.onDrop)
  }

  disconnect() {
    this.element.removeEventListener("dragover", this.onDragOver)
    this.element.removeEventListener("dragleave", this.onDragLeave)
    this.element.removeEventListener("drop", this.onDrop)
  }

  onDragOver = (e) => {
    e.preventDefault()
    this.element.classList.add("is-dragover")
  }

  onDragLeave = () => {
    this.element.classList.remove("is-dragover")
  }

  onDrop = (e) => {
    e.preventDefault()
    this.element.classList.remove("is-dragover")
    // Phase 8.5 implementation: send files to ActiveStorage direct upload
    // and refresh the resource list via turbo-stream.
    console.info("kb-upload: received", e.dataTransfer?.files?.length, "files")
  }
}
