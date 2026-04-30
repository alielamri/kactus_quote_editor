# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "@hotwired/turbo-rails.js"
pin "@hotwired/stimulus", to: "@hotwired/stimulus.js"
pin "@hotwired/stimulus-loading", to: "@hotwired/stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
