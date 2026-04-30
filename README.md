# Kactus Quote Editor

Rails 8 application for partners to create, edit, validate and audit quotes with line items, VAT and totals.

Extended technical notes: [DOCUMENTATION.md](DOCUMENTATION.md).

Self-review : [`docs/CODE_REVIEW.md`](docs/CODE_REVIEW.md).

---

## Table of contents

- [Features](#features)
- [Tech stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Running the app](#running-the-app)
- [Running the tests](#running-the-tests)
- [Project structure](#project-structure)
- [Domain model](#domain-model)
- [Improvement ideas](#improvement-ideas)

---

## Features

### Quote lifecycle

- Create, list, edit, delete and validate quotes
- **Draft** quotes are fully editable; **validated** quotes are read-only

### Items

- Add, edit, remove line items on the quote screen
- Each item: name, quantity, HT unit price (`decimal`, €), VAT rate (%)
- Items only editable while the quote is `draft`

### Calculations

Totals are computed when rendered (not stored columns):

| Total | Formula |
|---|---|
| Total HT (item) | `quantity × unit_price` |
| Total VAT (item) | `(total_ht × vat_rate) / 100`, rounded to 2 decimals |
| Total TTC (item) | `total_ht + total_vat` |
| Quote totals | Sum of item totals |

---

## Tech stack

| Concern | Choice |
|---|---|
| Web framework | Rails 8.1 (Hotwire by default) |
| Language | Ruby 3.4 |
| Database | PostgreSQL |
| Asset pipeline | Propshaft |
| CSS | Tailwind CSS v4 (`tailwindcss-rails`) + `app/assets/stylesheets/quotes.css` |
| JavaScript | esbuild (`jsbundling-rails`), Stimulus + Turbo |
| Tests | Minitest |

---

## Prerequisites

| Dependency | Recommended version | How to install |
|---|---|---|
| Ruby | **3.4.x** (see `.ruby-version`) | `asdf install ruby 3.4.7` or `rbenv install 3.4.7` |
| Node.js | **18+** | `asdf` / [nvm](https://github.com/nvm-sh/nvm) |
| PostgreSQL | **14+** | e.g. `brew install postgresql@16` |
| Bundler | matches `Gemfile.lock` | `gem install bundler` |
| Foreman | any recent version | `gem install foreman` (used by `bin/dev`) |

---

## Setup

### 1. Clone and enter the repository

```bash
git clone <repository-url>
cd kactus_quote_editor
```

### 2. Install dependencies

```bash
bundle install
npm install
```

### 3. Database

```bash
bin/rails db:create
bin/rails db:migrate
```

### 4. Assets (optional if you use `bin/dev`)

```bash
npm run build
bin/rails tailwindcss:build
```

---

## Running the app

### Development

```bash
bin/dev
```

Starts Rails, the JS watcher (`npm run dev`), and Tailwind watch (`Procfile.dev`). Then open **http://localhost:3000**.

### Rails only

After building assets once:

```bash
bin/rails server
```

### Console

```bash
bin/rails console
```

---

## Running the tests

```bash
bin/rails test
```

Single file / named test:

```bash
bin/rails test test/services/item_management_service_test.rb
bin/rails test test/models/quote_audit_test.rb -n test_tags_the_version_event_as_validate_when_status_moves_to_validated
```

---

## Project structure

```
app/
├── assets/stylesheets/quotes.css   # UI layer on top of Tailwind build
├── controllers/quotes_controller.rb
├── controllers/items_controller.rb
├── javascript/controllers/quote_form_controller.js
├── models/quote.rb
├── models/item.rb
├── services/
│   ├── quote_validation_service.rb
│   ├── quote_total_calculation_service.rb
│   └── item_management_service.rb
└── views/quotes/ … items/ … shared/
```

---

## Domain model

```
+----------------+        1     N        +----------------+
|     Quote      |---------------------->|      Item      |
+----------------+                       +----------------+
| name           |                       | name           |
| status (enum)  |                       | quantity       |
| draft          |                       | unit_price     |
| validated      |                       | vat_rate       |
+----------------+                       +----------------+
```

---

## Improvement ideas

These are intentionally **not** in the current code — they would be the next
items I'd shape with a PM in a real squad.

### Code quality / robustness
- **Integration tests** at the controller level (`ActionDispatch::IntegrationTest`)
  asserting the full request/response cycle, including the redirect-with-flash
  on validated-quote attempts. Today only the unit layer is covered.
- **System tests** (Capybara + Selenium) to lock the Stimulus interactions
  (toggling the new-item form, confirmation dialogs).
- **`bullet`** gem in development to detect any future N+1 regression at the
  request level.
- **Request-level query budget assertion**
  (`assert_queries_count`) on the show action to prevent regressions on the
  N+1 work.

### Domain
- **`whodunnit`** — once a `User` model exists, set `current_user.id` on
  `PaperTrail.request.whodunnit` in `ApplicationController` so every version
  records who did what.
- **Soft-delete** on quotes (`deleted_at`) instead of hard `destroy`, to keep
  the audit trail joinable with live data.
- **Quote duplication** ("create from this") to speed up partners' workflow.
- **PDF export** of a validated quote (Prawn or wkhtmltopdf).
- **Background totals caching** on quotes with many items, recomputed via
  `after_save` on `Item` (probably overkill until volumes prove it).

### Product
- **Quote versioning UX** built on top of `paper_trail.reify`: show a history
  side-panel with diffs and a "view as of" mode.
- **Currency / locale** — today the partner currency is implicit (`€`).
  Externalizing it is mostly an `I18n` + a `currency` column on `Quote`.
- **Authorization** — when users exist, partners must only see their own
  quotes; the `before_action :set_quote(_with_items)` is the natural place
  to scope by `current_user`.

---
