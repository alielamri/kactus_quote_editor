import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleNewItemForm(event) {
    event.preventDefault()
    const form = document.getElementById('new-item-form')
    if (!form) return
    if (form.hasAttribute('hidden')) {
      form.removeAttribute('hidden')
    } else {
      form.setAttribute('hidden', '')
    }
  }
}
