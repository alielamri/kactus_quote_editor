_Short README and improvement ideas: [`README.md`](README.md)._

---

# Kactus Quote Editor

A Rails 8 application that lets partners create, edit, validate and audit quotes
(`devis`) with their line items (`items`), VAT rates and totals.

This repository is a technical-test deliverable. The focus is on **production-grade
code quality** rather than UI polish: explicit service objects, transactions, audit
trail with `paper_trail`, N+1 awareness, and a comprehensive test suite.

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
- [Architectural decisions](#architectural-decisions)
- [Audit trail](#audit-trail)
- [Troubleshooting](#troubleshooting)
- [Improvement ideas](#improvement-ideas)

---

## Features

### Quote lifecycle
- Create, list, edit, delete and validate quotes
- A quote is either **draft** (fully editable) or **validated** (read-only, locked)
- The validated → draft transition is intentionally not exposed (auditable, irreversible)

### Items
- Add, edit, remove line items inside a quote
- Each item has a name, quantity, HT unit price (decimal `€`), and a VAT rate (%)
- Items can only be touched while the parent quote is `draft`

### Calculations
Totals are computed at request time, not stored:

| Total | Formula |
|---|---|
| Total HT (item) | `quantity × unit_price` |
| Total VAT (item) | `(total_ht × vat_rate) / 100`, rounded to 2 decimals |
| Total TTC (item) | `total_ht + total_vat` |
| Quote totals | Sum of the corresponding item totals |

### Audit trail
Every create / update / destroy on a quote or an item is recorded by
[`paper_trail`](https://github.com/paper-trail-gem/paper_trail) in the `versions`
table (Postgres JSONB). The transition `draft → validated` is recorded under a
custom event name `validate` to make the audit log readable from a business
standpoint.

---

## Tech stack

| Concern | Choice |
|---|---|
| Web framework | Rails 8.1 (Hotwire by default) |
| Language | Ruby 3.4 |
| Database | PostgreSQL |
| Asset pipeline | Propshaft |
| CSS | Tailwind CSS v4 (via `tailwindcss-rails`) + a custom design system in `app/assets/stylesheets/quotes.css` |
| JavaScript | esbuild via `jsbundling-rails`, Stimulus + Turbo |
| Audit trail | `paper_trail` |
| Tests | Minitest (Rails default) |

---

## Prerequisites

You need the following installed locally:

| Dependency | Recommended version | How to install |
|---|---|---|
| Ruby | **3.4.x** (matches `.ruby-version`) | `asdf install ruby 3.4.7` or `rbenv install 3.4.7` |
| Node.js | **18.x** or higher | `asdf install nodejs 20` or via [nvm](https://github.com/nvm-sh/nvm) |
| PostgreSQL | **14+** | macOS: `brew install postgresql@16 && brew services start postgresql@16` |
| Bundler | latest (matches `Gemfile.lock`) | `gem install bundler` |
| Foreman | latest (used by `bin/dev`) | `gem install foreman` (system-wide, not in `Gemfile`) |

> **PostgreSQL note**
> The default `config/database.yml` connects through a Unix socket and uses your
> OS user as the database role. If your local Postgres only accepts TCP
> connections (e.g. Docker, Postgres.app on certain setups), prefix every
> `bin/rails db:*` command with `PGHOST=localhost`, or set it once for the
> shell: `export PGHOST=localhost`.

---

## Setup

### 1. Clone and enter the repository

```bash
git clone <repository-url>
cd kactus_quote_editor
```

### 2. Install Ruby and JavaScript dependencies

```bash
bundle install
npm install
```

### 3. Create and migrate the databases

```bash
bin/rails db:create
bin/rails db:migrate
```

This applies four migrations:

| Migration | Purpose |
|---|---|
| `CreateQuotes` | `quotes` table (name, status enum) |
| `CreateItems` | `items` table (decimal `unit_price`, decimal `vat_rate`, `quote_id` FK) |
| `CreateVersions` | `paper_trail` versions table (JSONB `object`, indexed on `[item_type, item_id]`, `event`, `created_at`) |
| `AddObjectChangesToVersions` | Adds the JSONB `object_changes` column to `versions` |

### 4. Build assets once (optional, only useful if you don't run `bin/dev`)

```bash
npm run build               # bundle JS to app/assets/builds/application.js
bin/rails tailwindcss:build # build Tailwind CSS to app/assets/builds/tailwind.css
```

You can skip this step when using `bin/dev` (see below) — both watchers run in parallel.

---

## Running the app

### Development

The recommended way to run everything in parallel (Rails server + JS watcher + CSS watcher):

```bash
bin/dev
```

This is a thin wrapper around `foreman start -f Procfile.dev`, which starts:

```
web: bin/rails server
js:  npm run dev
css: bin/rails tailwindcss:watch[always]
```

> The `[always]` flag is important: without it, `tailwindcss:watch` exits as soon
> as stdin is closed (foreman quirk), which would shut the whole process group down.

The app is then available at: **http://localhost:3000**

### Plain Rails (no watchers)

If you don't need to edit the front-end, you can also run just the server after
building the assets once (see step 4 above):

```bash
bin/rails server
```

### Console / one-off scripts

```bash
bin/rails console
bin/rails runner 'puts Quote.recent.count'
```

---

## Running the tests

The whole test suite (50 tests, 79 assertions) runs in well under a second:

```bash
bin/rails test
```

To run a single file or a single test:

```bash
bin/rails test test/services/item_management_service_test.rb
bin/rails test test/models/quote_audit_test.rb -n test_tags_the_version_event_as_validate_when_status_moves_to_validated
```

What is covered:

| Layer | Files |
|---|---|
| Service objects | `test/services/quote_validation_service_test.rb`, `item_management_service_test.rb` (incl. transactional rollback) |
| Audit trail | `test/models/quote_audit_test.rb`, `test/models/item_audit_test.rb` |

---

## Project structure

Only the test-relevant parts are shown — the rest is a vanilla Rails 8 skeleton.

```
app/
├── assets/
│   ├── stylesheets/
│   │   └── quotes.css            # Custom design system (palette, .page, .icon-btn, .btn, ...)
│   └── tailwind/
│       └── application.css       # Tailwind entry point (only @import "tailwindcss";)
├── controllers/
│   ├── quotes_controller.rb
│   └── items_controller.rb
├── javascript/
│   ├── application.js            # Stimulus + Turbo bootstrap
│   └── controllers/
│       └── quote_form_controller.js   # Toggles the "new item" inline form
├── models/
│   ├── quote.rb
│   └── item.rb
├── services/                     # Business logic extracted from controllers
│   ├── quote_validation_service.rb
│   └── item_management_service.rb
└── views/
    ├── quotes/{index,new,edit,show}.html.erb
    ├── items/{_form,_list,edit}.html.erb
    └── shared/{_quote_header,_quote_actions,_total_card}.html.erb
```

---

## Domain model

```
+----------------+        1     N        +----------------+
|     Quote      |---------------------->|      Item      |
+----------------+                       +----------------+
| name           |                       | name           |
| status (enum)  |                       | quantity (int) |
|   draft        |                       | unit_price (€) |
|   validated    |                       | vat_rate (%)   |
+----------------+                       +----------------+
        |                                       |
        |  paper_trail                          |  paper_trail
        |                                       |
        v                                       v
+--------------------------------------------------------+
|  versions  (item_type, item_id, event, object,         |
|             object_changes, whodunnit, created_at)     |
+--------------------------------------------------------+
```

### Why `unit_price` is a `decimal` (and not integer cents)

Money is traditionally stored in cents to avoid floating-point precision issues.
We deliberately chose **`decimal(10, 2)`** here:

- Postgres `decimal` is **exact arithmetic** — there is no float-rounding bug.
- Forms and reports work with euros directly, which is more intuitive for partners.
- The downside ("conversion every time") doesn't apply to fixed-precision decimals.

---

## Architectural decisions

### Service objects

Two services live in `app/services/`. The rule: **a controller orchestrates,
it doesn't compute**. Each service returns a `{ success:, message: | error: }`
hash so controllers stay flat.

| Service | Responsibility |
|---|---|
| `QuoteValidationService` | `can_modify?` for draft vs validated, and `validation_message_for` for the correct flash after an update vs a transition to `validated`. |
| `ItemManagementService` | Wraps `create / update / destroy` of items in an explicit `ActiveRecord::Base.transaction`. Returns a structured result; controllers only translate it into a redirect. On validation failure, `error` is **`ActiveModel` full messages** (partner-visible diagnostics). |

**Quote totals** (`Total HT` / `TVA` / `TTC`) live on **`Quote#total_ht`**, `#total_vat`, `#total_ttc` — they sum `Item` line maths in memory (no duplicate service).

### Explicit transactions

Even when a single `save!` already runs in an implicit transaction, the services
wrap operations in `ActiveRecord::Base.transaction { ... }`:

```ruby
ActiveRecord::Base.transaction do
  item.save!
end
```

This is intentional:

1. It **documents the boundary** — future maintainers know where the atomic unit is.
2. Adding a second write (e.g. notifying another model) automatically inherits
   the same transaction without anyone forgetting.
3. The `paper_trail` version is created inside the same transaction, so we can
   never end up with a saved record without its audit row, or vice-versa.

### N+1 prevention

The codebase has been audited for N+1 queries:

| Page | Queries |
|---|---|
| `GET /quotes` | **1** — loads quotes only (no `includes(:items)` because the index doesn't display items). |
| `GET /quotes/:id` | **2** — loads the quote and preloads its items via `set_quote_with_items` (a dedicated `before_action`). The view then iterates and computes all three totals from the same in-memory collection. |

`set_quote` (used by `edit` / `update` / `destroy`) deliberately does **not**
preload items, since those actions don't need them.

The reverse association `Item#quote` is auto-detected as the inverse of
`Quote#items` by Rails 7+, so `item.quote.draft?` (called in
`Item#quote_must_not_be_validated`) does **not** trigger an extra query.

---

## Audit trail

We use [`paper_trail`](https://github.com/paper-trail-gem/paper_trail) rather
than rolling our own `AuditLog` model. Rationale:

- Battle-tested, ~30M downloads, used by GitHub and Shopify.
- Comes with `whodunnit`, `reify` (rebuild a previous in-memory state) and
  point-in-time queries — all features you eventually want for a billing system.
- Less code to maintain than a custom solution.

### Configuration choices

- **JSONB columns** for `object` and `object_changes` (configured in
  `db/migrate/2026..._create_versions.rb`). This is more compact and queryable
  than the default `text + YAML`.
- **JSON serializer** (`config/initializers/paper_trail.rb`) to match the JSONB
  storage.
- **`ignore: [:updated_at]`** on both models — `updated_at`-only changes never
  produce a version.
- **Custom event `validate`** — the `Quote#tag_validate_event_for_paper_trail`
  callback rewrites the event from `update` to `validate` when the status
  transitions to `validated`. Audit logs read like a business journal.

### Querying versions

```ruby
quote = Quote.last
quote.versions                       # => all versions, oldest first
quote.versions.where(event: 'validate').last
quote.versions.last.reify            # => an in-memory instance of the previous state
```

---

## Troubleshooting

### `Propshaft::MissingAssetError: The asset 'quotes.css' was not found in the load path.`

A stale `public/assets/.manifest.json` (left over from a previous
`bin/rails assets:precompile`) puts Propshaft into a static lookup mode that
ignores newly-added files. The fix is included in `.gitignore`, but if you ever
run `assets:precompile` locally and then add a new stylesheet:

```bash
rm -rf public/assets
bin/rails server   # restart the server
```

### `bin/dev` shuts down right after boot (`css.1 exited with code 0`)

This is `tailwindcss:watch` exiting when stdin closes. Make sure the Procfile
uses the `[always]` flag:

```
css: bin/rails tailwindcss:watch[always]
```

### `PG::ConnectionBad: connection to server on socket "..." failed`

Postgres is not listening on a Unix socket. Either:

```bash
export PGHOST=localhost
```

…or update `config/database.yml` to set `host: localhost` for `development:` and
`test:`.

### GitHub shows an empty README on the repository homepage

GitHub **only** renders the markdown file named **`README.md` at the repository
root** on your **default branch** (`main` vs `master`). Checklist:

1. **Push your local commits** — if nothing was pushed after the README rewrite,
   GitHub still shows whatever was there before (often an empty file):

   ```bash
   git remote -v                    # ensure origin points at your GitHub repo
   git push -u origin main         # or your branch name
   ```

2. **Default branch** — in GitHub: **Settings → General → Default branch** must
   match the branch that contains `README.md` (usually `main`).

3. **Repository root vs subfolder** — if the Git remote tracks a **parent**
   folder (e.g. `Desktop/KactusTest`) while the full documentation lives only in
   `kactus_quote_editor/README.md`, the homepage looks empty until you add a
   `README.md` **at that parent root** (even a short page linking into
   `kactus_quote_editor/README.md` is enough).

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
