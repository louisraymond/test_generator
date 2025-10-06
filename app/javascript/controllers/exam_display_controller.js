import { Controller } from "@hotwired/stimulus"

// Manages exam display settings (font size, spacing)
export default class extends Controller {
  static targets = ["presetButtons"]

  // Presets: compact, normal, comfortable, large
  presets = {
    compact: {
      fontSize: "12pt",
      lineHeight: "1.4",
      questionMargin: "12pt",
      titleSize: "16pt",
      label: "Compact"
    },
    normal: {
      fontSize: "14pt",
      lineHeight: "1.6",
      questionMargin: "18pt",
      titleSize: "18pt",
      label: "Normal"
    },
    comfortable: {
      fontSize: "16pt",
      lineHeight: "1.8",
      questionMargin: "24pt",
      titleSize: "20pt",
      label: "Comfortable"
    },
    large: {
      fontSize: "18pt",
      lineHeight: "2.0",
      questionMargin: "30pt",
      titleSize: "22pt",
      label: "Large Print"
    }
  }

  connect() {
    // Load saved preference from localStorage
    const saved = localStorage.getItem('examDisplayPreset')
    const preset = saved || 'normal'
    this.applyPreset(preset, false)
  }

  applyPreset(presetName, save = true) {
    const preset = this.presets[presetName]
    if (!preset) return

    // Find the page element (it's a sibling of the header)
    const page = document.querySelector('.page')
    if (!page) return
    
    // Apply CSS custom properties to the page
    page.style.setProperty('--exam-font-size', preset.fontSize)
    page.style.setProperty('--exam-line-height', preset.lineHeight)
    page.style.setProperty('--exam-question-margin', preset.questionMargin)
    page.style.setProperty('--exam-title-size', preset.titleSize)

    // Also apply to body for global effect
    document.body.style.setProperty('--exam-font-size', preset.fontSize)
    document.body.style.setProperty('--exam-line-height', preset.lineHeight)

    // Update active button
    this.presetButtonsTargets.forEach(button => {
      if (button.dataset.preset === presetName) {
        button.classList.add('is-active')
      } else {
        button.classList.remove('is-active')
      }
    })

    // Save to localStorage
    if (save) {
      localStorage.setItem('examDisplayPreset', presetName)
    }
  }

  selectPreset(event) {
    const preset = event.currentTarget.dataset.preset
    this.applyPreset(preset, true)
  }
}

