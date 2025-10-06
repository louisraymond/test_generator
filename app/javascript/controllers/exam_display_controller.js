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
        // Check for URL parameters first
        const urlParams = new URLSearchParams(window.location.search)
        const urlFontSize = urlParams.get('font_size')
        const urlSpacing = urlParams.get('question_spacing')

        if (urlFontSize || urlSpacing) {
            // Apply URL parameters
            if (urlFontSize) {
                this.applyCustomFontSize(`${urlFontSize}pt`)
                this.updateSliderAndInput('fontSize', urlFontSize)
            }
            if (urlSpacing) {
                this.applyCustomSpacing(`${urlSpacing}pt`)
                this.updateSliderAndInput('spacing', urlSpacing)
            }
            // Update PDF link with URL parameters
            this.updatePdfLink()
        } else {
            // Load saved preference from localStorage
            const saved = localStorage.getItem('examDisplayPreset')
            const preset = saved || 'normal'
            this.applyPreset(preset, false)

            // Load custom values from localStorage
            this.loadCustomValues()
        }
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

        // Update PDF link with current font size
        this.updatePdfLink()

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

        // Update PDF link with current font size
        this.updatePdfLink()
    }

    // Apply custom spacing
    applyCustomSpacing(spacing) {
        const pages = document.querySelectorAll('.page')
        if (pages.length === 0) return

        pages.forEach(page => {
            page.style.setProperty('--exam-question-margin', spacing)
        })

        // Update PDF link with current spacing
        this.updatePdfLink()
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

    // Update PDF link with current font size and spacing
    updatePdfLink() {
        const pdfLink = document.getElementById('pdf-link')
        if (!pdfLink) return

        // Get current values from URL parameters or from the first page element
        const urlParams = new URLSearchParams(window.location.search)
        const urlFontSize = urlParams.get('font_size')
        const urlSpacing = urlParams.get('question_spacing')

        let currentFontSize, currentSpacing

        if (urlFontSize) {
            currentFontSize = `${urlFontSize}pt`
        } else {
            const firstPage = document.querySelector('.page')
            currentFontSize = firstPage ? firstPage.style.getPropertyValue('--exam-font-size') || '14pt' : '14pt'
        }

        if (urlSpacing) {
            currentSpacing = `${urlSpacing}pt`
        } else {
            const firstPage = document.querySelector('.page')
            currentSpacing = firstPage ? firstPage.style.getPropertyValue('--exam-question-margin') || '18pt' : '18pt'
        }

        // Extract font size number (e.g., "9pt" -> "9")
        const fontSizeNumber = currentFontSize.replace('pt', '')
        const spacingNumber = currentSpacing.replace('pt', '')

        // Update the href with current parameters
        const url = new URL(pdfLink.href)
        url.searchParams.set('font_size', fontSizeNumber)
        url.searchParams.set('question_spacing', spacingNumber)
        pdfLink.href = url.toString()
    }

    // Update slider and input values
    updateSliderAndInput(type, value) {
        if (type === 'fontSize') {
            if (this.hasFontSizeSliderTarget) {
                this.fontSizeSliderTarget.value = value
            }
            if (this.hasFontSizeInputTarget) {
                this.fontSizeInputTarget.value = value
            }
            if (this.hasFontSizeValueTarget) {
                this.fontSizeValueTarget.textContent = `${value}pt`
            }
        } else if (type === 'spacing') {
            if (this.hasSpacingSliderTarget) {
                this.spacingSliderTarget.value = value
            }
            if (this.hasSpacingInputTarget) {
                this.spacingInputTarget.value = value
            }
            if (this.hasSpacingValueTarget) {
                this.spacingValueTarget.textContent = `${value}pt`
            }
        }
    }
}