import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import QuoteFormController from "./controllers/quote_form_controller.js"

const application = Application.start()

// Manually register the controller
application.register("quote-form", QuoteFormController)

export { application }



