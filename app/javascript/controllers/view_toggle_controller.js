import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["cardView", "tableView", "cardBtn", "tableBtn"]

    connect() {
        // Load saved preference from localStorage
        const savedView = localStorage.getItem('topicsViewPreference') || 'card'
        this.switchToView(savedView)
    }

    switchToCard() {
        this.switchToView('card')
    }

    switchToTable() {
        this.switchToView('table')
    }

    switchToView(view) {
        if (view === 'card') {
            this.cardViewTarget.style.display = 'grid'
            this.tableViewTarget.style.display = 'none'
            this.cardBtnTarget.classList.add('active')
            this.tableBtnTarget.classList.remove('active')
        } else {
            this.cardViewTarget.style.display = 'none'
            this.tableViewTarget.style.display = 'block'
            this.cardBtnTarget.classList.remove('active')
            this.tableBtnTarget.classList.add('active')
        }

        // Save preference
        localStorage.setItem('topicsViewPreference', view)
    }
}