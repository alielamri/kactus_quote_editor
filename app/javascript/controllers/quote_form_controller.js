import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleNewItemForm(event) {
    event.preventDefault()
    const form = document.getElementById('new-item-form')
    form.classList.toggle('hidden')
  }
}
