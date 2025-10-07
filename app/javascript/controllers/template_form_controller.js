import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "sectionsContainer",
        "sectionTemplate",
        "sectionCard",
        "sourceRuleField",
        "questionRuleField"
    ]

  static values = {
    topics: Array,
    modules: Array,
    learningObjectives: Array,
    questions: Array
  }

    connect() {
        this.sectionIndex = this.sectionCardTargets.length

        // Parse JSON data from data attributes if not already set
        if (!this.hasTopicsValue) {
            const topicsData = this.element.dataset.topicsJson
            if (topicsData) {
                this.topicsValue = JSON.parse(topicsData)
            }
        }

        if (!this.hasModulesValue) {
            const modulesData = this.element.dataset.modulesJson
            if (modulesData) {
                this.modulesValue = JSON.parse(modulesData)
            }
        }

    if (!this.hasLearningObjectivesValue) {
      const losData = this.element.dataset.learningObjectivesJson
      if (losData) {
        this.learningObjectivesValue = JSON.parse(losData)
      }
    }
    
    if (!this.hasQuestionsValue) {
      const questionsData = this.element.dataset.questionsJson
      if (questionsData) {
        this.questionsValue = JSON.parse(questionsData)
      }
    }
  }

    buildSourceOptions() {
        let options = '<option value="">Select source</option>'

        // Add all topics by default
        if (this.topicsValue && this.topicsValue.length > 0) {
            this.topicsValue.forEach(topic => {
                options += `<option value="${topic.id}">${topic.name}</option>`
            })
        }

        return options
    }

    buildModuleOptions() {
        let options = '<option value="">Select source</option>'

        if (this.modulesValue && this.modulesValue.length > 0) {
            this.modulesValue.forEach(mod => {
                options += `<option value="${mod.id}">${mod.topic_name} → ${mod.name}</option>`
            })
        }

        return options
    }

  buildLearningObjectiveOptions() {
    let options = '<option value="">Select source</option>'
    
    if (this.learningObjectivesValue && this.learningObjectivesValue.length > 0) {
      this.learningObjectivesValue.forEach(lo => {
        const desc = lo.description.length > 50 ? lo.description.substring(0, 50) + '...' : lo.description
        options += `<option value="${lo.id}">${lo.module_path} → ${desc}</option>`
      })
    }
    
    return options
  }
  
  buildQuestionOptions() {
    let options = '<option value="">Select question</option>'
    
    if (this.questionsValue && this.questionsValue.length > 0) {
      // Group questions by topic
      const byTopic = {}
      this.questionsValue.forEach(q => {
        if (!byTopic[q.topic_name]) {
          byTopic[q.topic_name] = []
        }
        byTopic[q.topic_name].push(q)
      })
      
      // Build optgroups
      Object.keys(byTopic).sort().forEach(topicName => {
        options += `<optgroup label="${topicName}">`
        byTopic[topicName].forEach(q => {
          const label = `Q${q.id}: ${q.question_type} - ${q.stem || 'No stem'}`
          options += `<option value="${q.id}">${label}</option>`
        })
        options += '</optgroup>'
      })
    }
    
    return options
  }

    addSection(event) {
        event.preventDefault()

        const content = this.sectionTemplateTarget.innerHTML
        const newSection = content.replace(/NEW_SECTION_RECORD/g, new Date().getTime())

        const wrapper = document.createElement('div')
        wrapper.innerHTML = newSection

        // Update position field
        const positionInput = wrapper.querySelector('input[name*="[position]"]')
        if (positionInput) {
            positionInput.value = this.sectionIndex
        }

        this.sectionsContainerTarget.insertAdjacentHTML('beforeend', wrapper.innerHTML)
        this.sectionIndex++
    }

    removeSection(event) {
        event.preventDefault()
        const card = event.target.closest('.section-card')
        const destroyField = card.querySelector('input[name*="[_destroy]"]')

        if (destroyField) {
            destroyField.value = '1'
            card.style.display = 'none'
        } else {
            card.remove()
        }
    }

    addSourceRule(event) {
        event.preventDefault()
        const button = event.target.closest('button')
        const sectionIndex = button.dataset.sectionIndex
        const container = button.previousElementSibling

        const newId = new Date().getTime()
        const sourceOptions = this.buildSourceOptions() // Default to topics

        const template = `
      <div class="rule-field" data-template-form-target="sourceRuleField">
        <input type="hidden" name="exam_template[exam_sections_attributes][${sectionIndex}][section_source_rules_attributes][${newId}][_destroy]" value="false">
        
        <div class="rule-field__row">
          <div class="rule-field__select-group">
            <label class="rule-field__label" for="exam_template_exam_sections_attributes_${sectionIndex}_section_source_rules_attributes_${newId}_source_type">Type</label>
            <select class="rule-field__select" data-action="change->template-form#updateSourceDropdown" name="exam_template[exam_sections_attributes][${sectionIndex}][section_source_rules_attributes][${newId}][source_type]" id="exam_template_exam_sections_attributes_${sectionIndex}_section_source_rules_attributes_${newId}_source_type">
              <option value="">Select type</option>
              <option value="Topic" selected>Topic</option>
              <option value="TopicModule">Module</option>
              <option value="LearningObjective">Learning Objective</option>
            </select>
          </div>

          <div class="rule-field__select-group">
            <label class="rule-field__label" for="exam_template_exam_sections_attributes_${sectionIndex}_section_source_rules_attributes_${newId}_source_id">Source</label>
            <select class="rule-field__select" name="exam_template[exam_sections_attributes][${sectionIndex}][section_source_rules_attributes][${newId}][source_id]" id="exam_template_exam_sections_attributes_${sectionIndex}_section_source_rules_attributes_${newId}_source_id">
              ${sourceOptions}
            </select>
          </div>

          <div class="rule-field__input-group">
            <label class="rule-field__label" for="exam_template_exam_sections_attributes_${sectionIndex}_section_source_rules_attributes_${newId}_weight">Weight</label>
            <input class="rule-field__input" type="number" min="1" value="1" name="exam_template[exam_sections_attributes][${sectionIndex}][section_source_rules_attributes][${newId}][weight]" id="exam_template_exam_sections_attributes_${sectionIndex}_section_source_rules_attributes_${newId}_weight">
          </div>

          <div class="rule-field__input-group">
            <label class="rule-field__label" for="exam_template_exam_sections_attributes_${sectionIndex}_section_source_rules_attributes_${newId}_question_count_override">Exact Count</label>
            <input class="rule-field__input" type="number" min="0" placeholder="Optional" name="exam_template[exam_sections_attributes][${sectionIndex}][section_source_rules_attributes][${newId}][question_count_override]" id="exam_template_exam_sections_attributes_${sectionIndex}_section_source_rules_attributes_${newId}_question_count_override">
          </div>

          <button type="button" class="btn btn--small btn--danger rule-field__remove" data-action="click->template-form#removeSourceRule">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
          </button>
        </div>
      </div>
    `

        container.insertAdjacentHTML('beforeend', template)
    }

    updateSourceDropdown(event) {
        const typeSelect = event.target
        const sourceType = typeSelect.value
        const ruleField = typeSelect.closest('.rule-field')
        const sourceSelect = ruleField.querySelector('select[name*="[source_id]"]')

        let options = ''
        switch (sourceType) {
            case 'Topic':
                options = this.buildSourceOptions()
                break
            case 'TopicModule':
                options = this.buildModuleOptions()
                break
            case 'LearningObjective':
                options = this.buildLearningObjectiveOptions()
                break
            default:
                options = '<option value="">Select source</option>'
        }

        sourceSelect.innerHTML = options
    }

    removeSourceRule(event) {
        event.preventDefault()
        const field = event.target.closest('.rule-field')
        const destroyField = field.querySelector('input[name*="[_destroy]"]')

        if (destroyField && destroyField.value !== 'false') {
            destroyField.value = '1'
            field.style.display = 'none'
        } else {
            field.remove()
        }
    }

    addQuestionRule(event) {
        event.preventDefault()
        const button = event.target.closest('button')
        const sectionIndex = button.dataset.sectionIndex
        const container = button.previousElementSibling

        const newId = new Date().getTime()
        const questionOptions = this.buildQuestionOptions()
        
        const template = `
      <div class="rule-field" data-template-form-target="questionRuleField">
        <input type="hidden" name="exam_template[exam_sections_attributes][${sectionIndex}][section_question_rules_attributes][${newId}][_destroy]" value="false">
        
        <div class="rule-field__row">
          <div class="rule-field__select-group">
            <label class="rule-field__label" for="exam_template_exam_sections_attributes_${sectionIndex}_section_question_rules_attributes_${newId}_rule_type">Rule Type</label>
            <select class="rule-field__select" name="exam_template[exam_sections_attributes][${sectionIndex}][section_question_rules_attributes][${newId}][rule_type]" id="exam_template_exam_sections_attributes_${sectionIndex}_section_question_rules_attributes_${newId}_rule_type">
              <option value="">Select type</option>
              <option value="force_include">Force Include</option>
              <option value="exclude">Exclude</option>
            </select>
          </div>

          <div class="rule-field__select-group" style="grid-column: span 2;">
            <label class="rule-field__label" for="exam_template_exam_sections_attributes_${sectionIndex}_section_question_rules_attributes_${newId}_question_id">Question</label>
            <select class="rule-field__select" name="exam_template[exam_sections_attributes][${sectionIndex}][section_question_rules_attributes][${newId}][question_id]" id="exam_template_exam_sections_attributes_${sectionIndex}_section_question_rules_attributes_${newId}_question_id">
              ${questionOptions}
            </select>
          </div>

          <div class="rule-field__input-group">
            <label class="rule-field__label" for="exam_template_exam_sections_attributes_${sectionIndex}_section_question_rules_attributes_${newId}_repeat_count">Repeats</label>
            <input class="rule-field__input" type="number" min="1" value="1" name="exam_template[exam_sections_attributes][${sectionIndex}][section_question_rules_attributes][${newId}][repeat_count]" id="exam_template_exam_sections_attributes_${sectionIndex}_section_question_rules_attributes_${newId}_repeat_count">
          </div>

          <button type="button" class="btn btn--small btn--danger rule-field__remove" data-action="click->template-form#removeQuestionRule">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
          </button>
        </div>
      </div>
    `

        container.insertAdjacentHTML('beforeend', template)
    }

    removeQuestionRule(event) {
        event.preventDefault()
        const field = event.target.closest('.rule-field')
        const destroyField = field.querySelector('input[name*="[_destroy]"]')

        if (destroyField && destroyField.value !== 'false') {
            destroyField.value = '1'
            field.style.display = 'none'
        } else {
            field.remove()
        }
    }
}