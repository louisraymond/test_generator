import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form", "titleDisplay", "titleText", "titleInput",
    "overviewDisplay", "overviewText", "overviewInput",
    "modulesGrid", "emptyState", "moduleTemplate", "hiddenFields"
  ]
  static values = {
    persisted: Boolean
  }

  connect() {
    this.moduleIndex = 0
    this.modules = []
    this.updateEmptyState()
  }

  // Title editing
  editTitle(event) {
    event.stopPropagation()
    this.titleDisplayTarget.style.display = 'none'
    this.titleInputTarget.style.display = 'block'
    this.titleInputTarget.focus()
    this.titleInputTarget.select()
  }

  saveTitleOnBlur() {
    const value = this.titleInputTarget.value.trim()
    if (value) {
      this.titleTextTarget.textContent = value
    } else {
      this.titleTextTarget.textContent = 'Untitled Topic'
      this.titleInputTarget.value = ''
    }
    this.titleInputTarget.style.display = 'none'
    this.titleDisplayTarget.style.display = 'flex'
  }

  handleTitleKeydown(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      this.titleInputTarget.blur()
    } else if (event.key === 'Escape') {
      this.titleInputTarget.value = this.titleTextTarget.textContent === 'Untitled Topic' ? '' : this.titleTextTarget.textContent
      this.titleInputTarget.blur()
    }
  }

  // Overview editing
  editOverview(event) {
    event.stopPropagation()
    this.overviewDisplayTarget.style.display = 'none'
    this.overviewInputTarget.style.display = 'block'
    this.overviewInputTarget.focus()
  }

  saveOverviewOnBlur() {
    const value = this.overviewInputTarget.value.trim()
    if (value) {
      this.overviewTextTarget.innerHTML = value.replace(/\n/g, '<br>')
      this.overviewTextTarget.style.color = '#166534'
      this.overviewTextTarget.style.fontStyle = 'italic'
    } else {
      this.overviewTextTarget.innerHTML = '<em style="color: #9ca3af;">Click to add topic overview/description...</em>'
    }
    this.overviewInputTarget.style.display = 'none'
    this.overviewDisplayTarget.style.display = 'block'
  }

  // Module management
  addModule(event) {
    event.preventDefault()
    const template = this.moduleTemplateTarget.content.cloneNode(true)
    const moduleCard = template.querySelector('.module-card')
    const index = this.moduleIndex++
    
    moduleCard.dataset.moduleIndex = index
    moduleCard.querySelector('.module-title-text').textContent = `Module ${this.modules.length + 1}`
    
    this.modulesGridTarget.appendChild(template)
    this.modules.push({
      index: index,
      name: `Module ${this.modules.length + 1}`,
      description: ''
    })
    
    this.updateEmptyState()
    
    // Auto-focus the title for editing
    const newCard = this.modulesGridTarget.querySelector(`[data-module-index="${index}"]`)
    const titleElement = newCard.querySelector('.module-card__title')
    this.editModuleTitleForCard(newCard)
  }

  removeModule(event) {
    event.preventDefault()
    const moduleCard = event.target.closest('.module-card')
    const index = parseInt(moduleCard.dataset.moduleIndex)
    
    // Remove from modules array
    this.modules = this.modules.filter(m => m.index !== index)
    
    // Remove from DOM
    moduleCard.remove()
    
    this.updateEmptyState()
  }

  editModuleTitle(event) {
    event.stopPropagation()
    const moduleCard = event.target.closest('.module-card')
    this.editModuleTitleForCard(moduleCard)
  }

  editModuleTitleForCard(moduleCard) {
    const titleDisplay = moduleCard.querySelector('.module-card__title')
    const titleInput = moduleCard.querySelector('.module-title-input')
    const titleText = moduleCard.querySelector('.module-title-text')
    
    titleDisplay.style.display = 'none'
    titleInput.style.display = 'block'
    titleInput.value = titleText.textContent
    titleInput.focus()
    titleInput.select()
  }

  saveModuleTitle(event) {
    const input = event.target
    const moduleCard = input.closest('.module-card')
    const titleDisplay = moduleCard.querySelector('.module-card__title')
    const titleText = moduleCard.querySelector('.module-title-text')
    const index = parseInt(moduleCard.dataset.moduleIndex)
    
    const value = input.value.trim()
    if (value) {
      titleText.textContent = value
      const module = this.modules.find(m => m.index === index)
      if (module) module.name = value
    }
    
    input.style.display = 'none'
    titleDisplay.style.display = 'flex'
  }

  handleModuleTitleKeydown(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      event.target.blur()
    } else if (event.key === 'Escape') {
      const moduleCard = event.target.closest('.module-card')
      const titleText = moduleCard.querySelector('.module-title-text')
      event.target.value = titleText.textContent
      event.target.blur()
    }
  }

  editModuleDescription(event) {
    event.stopPropagation()
    const moduleCard = event.target.closest('.module-card')
    const descDisplay = moduleCard.querySelector('.module-card__description')
    const descInput = moduleCard.querySelector('.module-description-input')
    const descText = moduleCard.querySelector('.module-description-text')
    
    descDisplay.style.display = 'none'
    descInput.style.display = 'block'
    
    // Set current value if it's not the placeholder
    if (!descText.querySelector('em')) {
      descInput.value = descText.textContent
    }
    
    descInput.focus()
  }

  saveModuleDescription(event) {
    const input = event.target
    const moduleCard = input.closest('.module-card')
    const descDisplay = moduleCard.querySelector('.module-card__description')
    const descText = moduleCard.querySelector('.module-description-text')
    const index = parseInt(moduleCard.dataset.moduleIndex)
    
    const value = input.value.trim()
    if (value) {
      descText.innerHTML = value
      descText.style.color = '#64748b'
      const module = this.modules.find(m => m.index === index)
      if (module) module.description = value
    } else {
      descText.innerHTML = '<em style="color: #9ca3af;">Click to add description...</em>'
    }
    
    input.style.display = 'none'
    descDisplay.style.display = 'block'
  }

  updateEmptyState() {
    if (this.modules.length === 0) {
      this.emptyStateTarget.style.display = 'block'
      this.modulesGridTarget.style.display = 'none'
    } else {
      this.emptyStateTarget.style.display = 'none'
      this.modulesGridTarget.style.display = 'grid'
    }
  }

  prepareSubmit(event) {
    // Create hidden fields for modules
    this.hiddenFieldsTarget.innerHTML = ''
    
    this.modules.forEach((module, idx) => {
      const nameField = document.createElement('input')
      nameField.type = 'hidden'
      nameField.name = `topic[topic_modules_attributes][${idx}][name]`
      nameField.value = module.name
      this.hiddenFieldsTarget.appendChild(nameField)
      
      if (module.description) {
        const descField = document.createElement('input')
        descField.type = 'hidden'
        descField.name = `topic[topic_modules_attributes][${idx}][description]`
        descField.value = module.description
        this.hiddenFieldsTarget.appendChild(descField)
      }
    })
  }
}

