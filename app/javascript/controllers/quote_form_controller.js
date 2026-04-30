import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleNewItemForm(event) {
    console.log('toggleNewItemForm')
    event.preventDefault()
    const form = document.getElementById('new-item-form')
    if (form) {
      form.classList.toggle('hidden')
    }
  }
}

