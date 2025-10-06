import { Controller } from "@hotwired/stimulus"

// Renders LaTeX math expressions using KaTeX
// Usage: Add data-controller="math" to any element containing LaTeX
export default class extends Controller {
    connect() {
        this.renderMath()
    }

    renderMath() {
        // Wait for KaTeX to load
        if (typeof renderMathInElement === 'undefined') {
            setTimeout(() => this.renderMath(), 100)
            return
        }

        renderMathInElement(this.element, {
            delimiters: [
                { left: '$$', right: '$$', display: true },
                { left: '$', right: '$', display: false },
                { left: '\\(', right: '\\)', display: false },
                { left: '\\[', right: '\\]', display: true }
            ],
            throwOnError: false,
            errorColor: '#cc0000',
            strict: false,
            trust: false,
            fleqn: false,
            ignoredTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code']
        })
    }
}