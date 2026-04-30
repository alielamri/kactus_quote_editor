# Quick Start Guide

## Installation

```bash
cd kactus_quote_editor
bundle install
rails db:create db:migrate
bin/dev
```

Visit `http://localhost:3000` in your browser.

## Running Tests

```bash
rails test
```

## Development Server

The application uses `bin/dev` which runs:
- Rails server on port 3000
- Tailwind CSS builder for style compilation

## Project Structure

```
kactus_quote_editor/
├── app/
│   ├── controllers/          # Request handlers
│   ├── models/               # Business logic & validations
│   ├── views/                # HTML templates with Tailwind CSS
│   └── javascript/           # Stimulus JS controllers
├── config/                   # Configuration files
├── db/                       # Database migrations & schema
├── test/                     # Unit & model tests
├── README.md                 # Main documentation
├── IMPROVEMENTS.md           # Enhancement suggestions
└── Gemfile                   # Ruby dependencies
```

## Key Features

✅ Create, read, update, delete quotes
✅ Manage line items with automatic VAT calculation
✅ Quote validation to lock quotes
✅ Responsive design with Tailwind CSS
✅ Form interactions with Stimulus JS
✅ Model validations and error handling
✅ Comprehensive test coverage

## Technology Stack

- Rails 8.0
- PostgreSQL
- Tailwind CSS
- Stimulus JS
- Minitest
