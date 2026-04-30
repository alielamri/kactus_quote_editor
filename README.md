# Kactus Quote Editor

A Rails application for managing and editing invoices/quotes with line items, VAT calculation, and quote validation.

## Overview

Kactus Quote Editor is a B2B marketplace quote management tool that allows partners to:

- Create and manage multiple quotes
- Add line items with quantity, unit price, and VAT rate
- View detailed totals (ex. VAT, VAT amount, inc. VAT)
- Validate quotes to lock them from further modification
- Edit or delete draft quotes

## Requirements

- Ruby 3.4+
- Rails 8.0+
- PostgreSQL 14+
- Node.js 18+

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd kactus_quote_editor
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Setup Database

```bash
rails db:create db:migrate
```

### 4. Start the Application

```bash
bin/dev
```

The application will be available at `http://localhost:3000`

## Architecture

### Models

- **Quote**: Represents an invoice/quote with multiple items
  - Attributes: `name`, `status` (draft/validated)
  - Methods: `total_ht`, `total_vat`, `total_ttc` for calculations
  - Associations: `has_many :items, dependent: :destroy`

- **Item**: Line items within a quote
  - Attributes: `name`, `quantity`, `unit_price_cents`, `vat_rate`
  - Validations: presence, numericality constraints
  - Protection: cannot be modified if quote is validated

### Controllers

- **QuotesController**: Handles quote CRUD operations and validation
  - `index`: List all quotes (sorted by most recent)
  - `show`: Display quote with items and totals
  - `new/create`: Create new quote
  - `edit/update`: Modify draft quotes
  - `destroy`: Delete quotes
  - `validate`: Lock quote from further modification

- **ItemsController**: Handles item operations within quotes
  - `create`: Add new item to quote
  - `edit/update`: Modify item details
  - `destroy`: Remove item from quote

### Views

- **Quotes Index** (`views/quotes/index.html.erb`):
  - Table listing all quotes
  - Status indicators (draft/validated)
  - Quick actions (view, edit, delete)

- **Quote Show** (`views/quotes/show.html.erb`):
  - Detailed quote view
  - Items table with individual totals
  - Add/edit/delete items (only for draft quotes)
  - Quote-level totals displayed in cards
  - Validate/edit/delete quote buttons

- **Quote Form** (`views/quotes/new.html.erb`, `views/quotes/edit.html.erb`):
  - Simple form to create or edit quote name

- **Item Form** (`views/items/edit.html.erb`):
  - Form to edit item details

## Features

### Quote Management

- **Create**: Add new quotes with a name
- **Read**: View list of all quotes or detailed quote view
- **Update**: Modify quote name or items (only if draft)
- **Delete**: Remove quotes (only if draft)
- **Validate**: Lock quote to prevent modifications

### Item Management

- **Add Items**: Add line items with name, quantity, unit price, and VAT rate
- **Edit Items**: Modify item details (only if quote is draft)
- **Delete Items**: Remove items from quote (only if quote is draft)
- **Automatic Calculations**: VAT and totals calculated automatically

### Financial Calculations

All monetary values are stored in cents (as integers) to avoid floating-point precision issues:

- **Total HT** (ex. VAT): `quantity × unit_price`
- **Total VAT**: `(total_ht × vat_rate) / 100`
- **Total TTC** (inc. VAT): `total_ht + total_vat`

Quote-level totals are sums of item-level totals.

## User Experience

### States

1. **Draft Quote**: Fully editable. Users can add, modify, or delete items and the quote itself.
2. **Validated Quote**: Read-only. Quote cannot be modified or deleted. Used for completed orders.

### Navigation

- Home page shows quote list
- Clicking quote name opens detailed view
- "New Quote" button on list page creates new quote
- "Add Item" button visible only for draft quotes
- Edit/Delete actions only available for draft quotes

## Technology Stack

- **Framework**: Rails 8.0
- **Database**: PostgreSQL
- **Frontend**: Tailwind CSS + Stimulus JS
- **JavaScript bundling**: Importmap (no build step required)
- **Testing**: Minitest (Rails default)

## Testing

Run the test suite with:

```bash
rails test
```

Run specific test file:

```bash
rails test test/models/quote_test.rb
```

## Code Quality

The application follows Rails best practices:

- Validations at model level
- Before-action callbacks for authorization checks
- Consistent naming conventions
- DRY principles
- Proper error handling and user feedback
- Responsive UI with Tailwind CSS

## Deployment

The application includes a `Dockerfile` for containerized deployment. To deploy:

1. Set up production environment variables
2. Run database migrations: `rails db:migrate RAILS_ENV=production`
3. Precompile assets: `rails assets:precompile`
4. Deploy using Kamal or Docker

## Potential Improvements

1. **User Authentication**: Add user accounts to manage quotes per user
2. **PDF Export**: Generate quote PDFs for sharing with clients
3. **Email Notifications**: Send quote details via email
4. **Audit Trail**: Track quote modifications with timestamps and user details
5. **Batch Operations**: Update multiple items at once
6. **Custom VAT Rates**: Admin interface to manage company-specific VAT rates
7. **Quote Templates**: Save quote templates for quick creation
8. **Search & Filter**: Advanced filtering by date, status, total amount
9. **Localization**: Multi-language support and currency handling
10. **API**: RESTful API for third-party integrations

## License

This application is proprietary to Kactus and is provided as-is for evaluation purposes.

## Support

For issues or questions, please contact the development team.
