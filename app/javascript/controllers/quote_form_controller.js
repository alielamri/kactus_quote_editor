import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleNewItemForm(event) {
    event.preventDefault()
    const form = document.getElementById('new-item-form')
    if (form) {
      const isHidden = form.style.display === 'none'
      form.style.display = isHidden ? 'block' : 'none'
    }
  }
}
