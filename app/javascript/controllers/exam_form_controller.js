import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="exam-form"
export default class extends Controller {
    static targets = [
        "topicCheckbox", "weightInput", "typeCheckbox", "count", "availability", "typeList", "topicTable", "topicToggle", "typeToggle"
    ]

    connect() {
        this.updatePreview()
    }

    updatePreview() {
        const topic_ids = this.topicCheckboxTargets.filter(cb => cb.checked).map(cb => cb.value)
        const question_types = this.typeCheckboxTargets.filter(cb => cb.checked).map(cb => cb.value)
        const question_count = parseInt(this.countTarget.value || "0", 10)

        const weights = {}
        this.weightInputTargets.forEach(input => {
            if (input.value && parseFloat(input.value) > 0) {
                weights[input.dataset.topicId] = input.value
            }
        })

        const params = new URLSearchParams()
        topic_ids.forEach(id => params.append('topic_ids[]', id))
        question_types.forEach(t => params.append('question_types[]', t))
        params.append('question_count', isNaN(question_count) ? 0 : question_count)
        Object.entries(weights).forEach(([k, v]) => params.append(`topic_weights[${k}]`, v))

        fetch(`/exams/preview_counts?${params.toString()}`, { headers: { 'Accept': 'application/json' } })
            .then(r => r.ok ? r.json() : Promise.reject())
            .then(data => this.renderPreview(data))
            .catch(() => this.renderPreview({ total_available: 0, per_type: {}, per_topic: {}, suggested_allocation: {} }))
    }

    renderPreview(data) {
        // Update toggle states
        if (this.hasTopicToggleTarget) {
            const total = this.topicCheckboxTargets.length
            const selected = this.topicCheckboxTargets.filter(cb => cb.checked).length
            this.topicToggleTarget.checked = selected === total && total > 0
            this.topicToggleTarget.indeterminate = selected > 0 && selected < total
        }
        if (this.hasTypeToggleTarget) {
            const total = this.typeCheckboxTargets.length
            const selected = this.typeCheckboxTargets.filter(cb => cb.checked).length
            this.typeToggleTarget.checked = selected === total && total > 0
            this.typeToggleTarget.indeterminate = selected > 0 && selected < total
        }

        if (this.hasAvailabilityTarget) {
            this.availabilityTarget.textContent = `${data.total_available} available`
        }
        if (this.hasTypeListTarget) {
            this.typeListTarget.innerHTML = ''
            Object.entries(data.per_type).forEach(([type, cnt]) => {
                const li = document.createElement('span')
                li.className = 'chip'
                li.textContent = `${type} ${cnt}`
                this.typeListTarget.appendChild(li)
            })
        }
        if (this.hasTopicTableTarget) {
            this.topicTableTarget.innerHTML = ''
            Object.entries(data.per_topic).forEach(([tid, avail]) => {
                const tr = document.createElement('div')
                tr.className = 'topic-row'
                const alloc = data.suggested_allocation[tid] || 0
                tr.innerHTML = `<span class="topic-id">#${tid}</span><span class="topic-avail">${avail} avail</span><span class="topic-alloc">→ ${alloc} used</span>`
                this.topicTableTarget.appendChild(tr)
            })
        }
    }

    toggleAllTopics(event) {
        const checked = event.target.checked
        event.target.indeterminate = false
        this.topicCheckboxTargets.forEach(cb => cb.checked = checked)
        this.updatePreview()
    }

    toggleAllTypes(event) {
        const checked = event.target.checked
        event.target.indeterminate = false
        this.typeCheckboxTargets.forEach(cb => cb.checked = checked)
        this.updatePreview()
    }
}