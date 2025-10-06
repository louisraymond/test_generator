import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="topic-detail"
export default class extends Controller {
    static targets = [
        "categoryCard", "categoryBody", "chevron", "addLoForm", "loInput",
        "addCategoryForm", "categoryNameInput", "firstLoInput", "addCategoryButton"
    ]
    static values = {
        topicId: Number
    }

    connect() {
        // Expand all categories by default
        this.categoryCardTargets.forEach(card => {
            this.expandCategory(card)
        })
    }

    toggleCategory(event) {
        const categoryCard = event.currentTarget.closest('[data-category]')
        const body = categoryCard.querySelector('[data-topic-detail-target="categoryBody"]')

        if (body.style.display === 'none') {
            this.expandCategory(categoryCard)
        } else {
            this.collapseCategory(categoryCard)
        }
    }

    expandCategory(categoryCard) {
        const body = categoryCard.querySelector('[data-topic-detail-target="categoryBody"]')
        const chevron = categoryCard.querySelector('[data-topic-detail-target="chevron"]')

        body.style.display = 'block'
        chevron.style.transform = 'rotate(0deg)'
    }

    collapseCategory(categoryCard) {
        const body = categoryCard.querySelector('[data-topic-detail-target="categoryBody"]')
        const chevron = categoryCard.querySelector('[data-topic-detail-target="chevron"]')

        body.style.display = 'none'
        chevron.style.transform = 'rotate(-90deg)'
    }

    startAddLo(event) {
        const category = event.currentTarget.dataset.category
        const categoryCard = this.categoryCardTargets.find(card => card.dataset.category === category)

        // Hide the add button, show the form
        const addButton = event.currentTarget
        const addForm = categoryCard.querySelector('[data-topic-detail-target="addLoForm"]')

        addButton.style.display = 'none'
        addForm.style.display = 'block'

        // Store the category for saving
        this.currentAddingLoCategory = category
        this.currentAddingLoCategoryCard = categoryCard

        // Focus the input
        const input = addForm.querySelector('[data-topic-detail-target="loInput"]')
        input.focus()
    }

    cancelAddLo(event) {
        const categoryCard = this.currentAddingLoCategoryCard
        const addButton = categoryCard.querySelector('.btn-add-lo')
        const addForm = categoryCard.querySelector('[data-topic-detail-target="addLoForm"]')
        const input = addForm.querySelector('[data-topic-detail-target="loInput"]')

        addButton.style.display = 'flex'
        addForm.style.display = 'none'
        input.value = ''

        this.currentAddingLoCategory = null
        this.currentAddingLoCategoryCard = null
    }

    async saveLo(event) {
        const categoryCard = this.currentAddingLoCategoryCard
        const category = this.currentAddingLoCategory
        const addForm = categoryCard.querySelector('[data-topic-detail-target="addLoForm"]')
        const input = addForm.querySelector('[data-topic-detail-target="loInput"]')

        const description = input.value.trim()

        if (!description) {
            alert('Description is required')
            return
        }

        // Get module_id from the module section
        const moduleSection = categoryCard.closest('.module-section')
        const moduleId = moduleSection ? moduleSection.dataset.moduleId : null

        try {
            const loData = { description, category }
            if (moduleId) {
                loData.topic_module_id = moduleId
            }

            const response = await fetch(`/api/topics/${this.topicIdValue}/learning_objectives`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.csrfToken
                },
                body: JSON.stringify({
                    learning_objective: loData
                })
            })

            if (response.ok) {
                const data = await response.json()

                // Add the new LO to the list
                const loList = categoryCard.querySelector('.learning-objectives')
                const loCount = loList.querySelectorAll('.lo-item').length + 1

                const newLoHtml = `
          <div class="lo-item" data-lo-id="${data.id}">
            <div class="lo-item__content">
              <span class="lo-item__number">${loCount}</span>
              <span class="lo-item__text">${this.escapeHtml(data.description)}</span>
            </div>
            <a href="/questions/new?learning_objective_id=${data.id}" class="btn btn--small btn--primary lo-item__btn">Add Question</a>
          </div>
        `

                loList.insertAdjacentHTML('beforeend', newLoHtml)

                // Update the badge count
                const badge = categoryCard.querySelector('.category-card__badge')
                badge.textContent = loCount === 1 ? '1 outcome' : `${loCount} outcomes`

                // Update the number in the add form
                const numberBadge = addForm.querySelector('.lo-item__number')
                numberBadge.textContent = loCount + 1

                // Hide form, show button
                const addButton = categoryCard.querySelector('.btn-add-lo')
                addButton.style.display = 'flex'
                addForm.style.display = 'none'
                input.value = ''

                this.showFlash('Learning outcome added successfully!')
                this.currentAddingLoCategory = null
                this.currentAddingLoCategoryCard = null
            } else {
                const data = await response.json()
                alert(data.errors ? data.errors.join(', ') : 'Failed to add learning outcome')
            }
        } catch (error) {
            console.error('Error adding learning objective:', error)
            alert('Failed to add learning outcome')
        }
    }

    startAddCategory(event) {
        const addButton = event.currentTarget
        const moduleSection = addButton.closest('.module-section')

        // Store the module_id if we're in a module section
        this.currentModuleId = moduleSection ? moduleSection.dataset.moduleId : null

        const addForm = this.addCategoryFormTarget

        addButton.style.display = 'none'
        addForm.style.display = 'block'

        // Focus the category name input
        this.categoryNameInputTarget.focus()
    }

    handleCategoryKeydown(event) {
        if (event.key === 'Enter') {
            event.preventDefault()
            this.saveCategory()
        } else if (event.key === 'Escape') {
            event.preventDefault()
            this.cancelAddCategory()
        }
    }

    cancelAddCategory(event) {
        const addButton = this.addCategoryButtonTarget
        const addForm = this.addCategoryFormTarget

        addButton.style.display = 'flex'
        addForm.style.display = 'none'

        // Clear inputs
        this.categoryNameInputTarget.value = ''
        this.firstLoInputTarget.value = ''
    }

    async saveCategory(event) {
        const categoryName = this.categoryNameInputTarget.value.trim()
        const description = this.firstLoInputTarget.value.trim()

        if (!categoryName) {
            alert('Category name is required')
            this.categoryNameInputTarget.focus()
            return
        }

        if (!description) {
            alert('First learning outcome is required')
            this.firstLoInputTarget.focus()
            return
        }

        try {
            const loData = {
                description: description,
                category: categoryName
            }

            // Include module_id if we're adding to a module
            if (this.currentModuleId) {
                loData.topic_module_id = this.currentModuleId
            }

            const response = await fetch(`/api/topics/${this.topicIdValue}/learning_objectives`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.csrfToken
                },
                body: JSON.stringify({
                    learning_objective: loData
                })
            })

            if (response.ok) {
                // Reload the page to show the new category
                this.showFlash('Category added successfully!')
                setTimeout(() => window.location.reload(), 500)
            } else {
                const data = await response.json()
                alert(data.errors ? data.errors.join(', ') : 'Failed to add category')
            }
        } catch (error) {
            console.error('Error adding category:', error)
            alert('Failed to add category')
        }
    }

    async addModule(event) {
        const moduleName = prompt('Enter module name:')
        
        if (!moduleName || moduleName.trim() === '') {
            return
        }

        const moduleDescription = prompt('Enter module description (optional):')

        try {
            const response = await fetch(`/api/topics/${this.topicIdValue}/topic_modules`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': this.csrfToken
                },
                body: JSON.stringify({
                    topic_module: {
                        name: moduleName.trim(),
                        description: moduleDescription ? moduleDescription.trim() : ''
                    }
                })
            })

            if (response.ok) {
                this.showFlash('Module added successfully!')
                setTimeout(() => window.location.reload(), 500)
            } else {
                const data = await response.json()
                alert(data.errors ? data.errors.join(', ') : 'Failed to add module')
            }
        } catch (error) {
            console.error('Error adding module:', error)
            alert('Failed to add module')
        }
    }

    showFlash(message) {
        // Create flash message element
        const flash = document.createElement('div')
        flash.className = 'flash-message flash-message--success'
        flash.innerHTML = `
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
      <span>${this.escapeHtml(message)}</span>
    `

        document.body.appendChild(flash)

        // Remove after 3 seconds
        setTimeout(() => {
            flash.classList.add('flash-message--fade-out')
            setTimeout(() => flash.remove(), 300)
        }, 3000)
    }

    escapeHtml(text) {
        const div = document.createElement('div')
        div.textContent = text
        return div.innerHTML
    }

    get csrfToken() {
        return document.querySelector('meta[name="csrf-token"]').content
    }
}