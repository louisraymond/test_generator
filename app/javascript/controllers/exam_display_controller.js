import { Controller } from "@hotwired/stimulus"

// Manages exam display settings (font size, spacing)
export default class extends Controller {
    static targets = ["presetButtons", "fontSizeSlider", "fontSizeInput", "fontSizeValue", "spacingSlider", "spacingInput", "spacingValue"]

    // Presets: compact, normal, comfortable, large
    presets = {
        compact: {
            fontSize: "11pt",
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

        // Load custom values from localStorage
        this.loadCustomValues()
    }

    applyPreset(presetName, save = true) {
        const preset = this.presets[presetName]
        if (!preset) return

        // Find all page elements
        const pages = document.querySelectorAll('.page')
        if (pages.length === 0) return

        // Apply CSS custom properties to all pages
        pages.forEach(page => {
            page.style.setProperty('--exam-font-size', preset.fontSize)
            page.style.setProperty('--exam-line-height', preset.lineHeight)
            page.style.setProperty('--exam-question-margin', preset.questionMargin)
            page.style.setProperty('--exam-title-size', preset.titleSize)
        })

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

    // Custom font size controls
    updateFontSize(event) {
        const value = parseInt(event.target.value)
        const fontSize = `${value}pt`

        // Update both slider and input
        if (event.target === this.fontSizeSliderTarget) {
            this.fontSizeInputTarget.value = value
        } else {
            this.fontSizeSliderTarget.value = value
        }

        // Update display
        this.fontSizeValueTarget.textContent = fontSize

        // Apply to page
        this.applyCustomFontSize(fontSize)

        // Save to localStorage
        localStorage.setItem('examDisplayFontSize', fontSize)
    }

    // Custom spacing controls
    updateSpacing(event) {
        const value = parseInt(event.target.value)
        const spacing = `${value}pt`

        // Update both slider and input
        if (event.target === this.spacingSliderTarget) {
            this.spacingInputTarget.value = value
        } else {
            this.spacingSliderTarget.value = value
        }

        // Update display
        this.spacingValueTarget.textContent = spacing

        // Apply to page
        this.applyCustomSpacing(spacing)

        // Save to localStorage
        localStorage.setItem('examDisplaySpacing', spacing)
    }

    // Apply custom font size
    applyCustomFontSize(fontSize) {
        const pages = document.querySelectorAll('.page')
        if (pages.length === 0) return

        pages.forEach(page => {
            page.style.setProperty('--exam-font-size', fontSize)
        })
        document.body.style.setProperty('--exam-font-size', fontSize)
    }

    // Apply custom spacing
    applyCustomSpacing(spacing) {
        const pages = document.querySelectorAll('.page')
        if (pages.length === 0) return

        pages.forEach(page => {
            page.style.setProperty('--exam-question-margin', spacing)
        })
    }

    // Load custom values from localStorage
    loadCustomValues() {
        const savedFontSize = localStorage.getItem('examDisplayFontSize')
        const savedSpacing = localStorage.getItem('examDisplaySpacing')

        if (savedFontSize) {
            const fontSize = parseInt(savedFontSize.replace('pt', ''))
            this.fontSizeSliderTarget.value = fontSize
            this.fontSizeInputTarget.value = fontSize
            this.fontSizeValueTarget.textContent = savedFontSize
            this.applyCustomFontSize(savedFontSize)
        }

        if (savedSpacing) {
            const spacing = parseInt(savedSpacing.replace('pt', ''))
            this.spacingSliderTarget.value = spacing
            this.spacingInputTarget.value = spacing
            this.spacingValueTarget.textContent = savedSpacing
            this.applyCustomSpacing(savedSpacing)
        }
    }
}