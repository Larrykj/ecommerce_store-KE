# E-Commerce Store (Kenya Edition) 🇰🇪

A modern, responsive e-commerce web application built with **Ruby on Rails 8**. This application simulates a complete online shopping experience, tailored for the Kenyan market with KSh currency formatting.

## 🚀 Features

### Core Shopping Experience
*   **🛒 Product Management**: Browse products in a responsive grid with full-text search, price filtering, and stock status.
*   **🛍️ Shopping Cart**: 
    *   Add items, update quantities, real-time stock validation.
    *   Prevent overselling with inventory checks.
    *   Persistent cart with Turbo ReactiveUI updates.
*   **💳 Checkout System**: 
    *   Multiple payment modes: Test Card, Cash on Delivery, Manual Confirmation.
    *   **Stock-Safe Transactions**: Database transactions with row locking prevent race conditions.
    *   **Order Confirmation**: PDF invoices and email receipts.
*   **⭐ Reviews & Ratings**: Users can rate and review products with helpful voting.
*   **❤️ Wishlist**: Save products for later with one-click additions.
*   **📊 Product Comparison**: Compare multiple products side-by-side.

### Admin & Management  
*   **🔐 Admin Portal**: Role-based access control for admins only.
    *   Protected write actions: Only admins can create/edit/delete products and categories.
    *   Dashboard with revenue stats, order metrics, user count.
    *   Quick-access management links for orders, products, users.
*   **📦 Admin Controls**:
    *   Manage all products with variant support (sizes, colors, SKUs).
    *   Manage categories with bulk operations.
    *   View and update order statuses with email notifications.
    *   Manage promo codes, shipping methods, gift cards, return requests.
*   **💰 Orders**:
    *   Full order lifecycle: Pending → Paid → Processing → Shipped → Delivered.
    *   Status transitions with validation and email alerts.
    *   Invoice generation and PDF downloads.
    *   Return request management.

### Advanced Features
*   **🔍 Full-Text Search**: PostgreSQL-powered search across product names and descriptions.
*   **📄 Pagination**: Pagy gem for fast, lightweight pagination.
*   **🎁 Promo Codes**: Discount codes with expiration and usage limits.
*   **🚚 Shipping**: Multiple shipping methods with cost calculation.
*   **💌 Email Notifications**: Order confirmations, status updates, shipped alerts.
*   **🔐 Security**:
    *   JWT-style tokens for sensitive data (names, emails, phone numbers encrypted).
    *   CSRF protection and secure password handling.
    *   Row-level database locking for concurrent checkout safety.
*   **🌍 Localization**: All prices in Kenyan Shillings (KSh) with proper formatting.
*   **📱 Mobile Responsive**: Full Bootstrap 5 mobile-first design.
*   **🔄 Real-Time UI**: Turbo Rails for instant cart updates without page reloads.

### Payment & Transactions
*   **Sandbox Mode**: Test payment flows without real processing.
*   **Payment Methods**: 
    - Test Card (auto-completes for demo)
    - Cash on Delivery (COD)
    - Manual Admin Confirmation
*   **Transaction Safety**: ACID-compliant orders with atomic stock deductions.

## 🛠️ Prerequisites

Ensure you have the following installed:
*   Ruby 3.3+
*   Rails 8.1.2+
*   PostgreSQL 14+ (or SQLite3 for development)
*   Node.js 20+

## 🔐 Admin Setup

This application uses role-based access control with an `admin` boolean flag on the User model.

### Creating an Admin User

1. **Via Rails Console**:
```bash
rails console
user = User.find(1)  # Find an existing user
user.update(admin: true)
user.save!
```

2. **After User Registration**:
   - Users register as regular customers
   - Admin users can be created only by existing admins via the admin dashboard
   - First admin must be set up via console

### Admin Access

*   **Dashboard**: Navigate to [http://localhost:3000/admin](http://localhost:3000/admin)
*   **Protected Actions**: All admin-only routes are protected by `AdminAuthenticatable` concern
*   **Redirect**: Non-admin users accessing admin areas are redirected to home
*   **Authorization Helpers**: User model provides `can_manage_products?`, `can_manage_categories?`, `can_manage_orders?`, etc.

## 📦 Getting Started

Follow these steps to get a local copy up and running.

### 1. Clone the Repository
```bash
git clone https://github.com/Larrykj/ecommerce_store-KE.git
cd ecommerce_store-KE
```

### 2. Install Dependencies
Install the required Ruby gems:
```bash
bundle install
```

### 3. Environment Configuration
Copy the example environment file and configure as needed:
```bash
cp env.example .env
```

Key environment variables:
- `DATABASE_URL`: PostgreSQL connection string
- `STRIPE_PUBLIC_KEY`: Stripe publishable key (test mode)
- `STRIPE_SECRET_KEY`: Stripe secret key (test mode)
- `RAILS_MASTER_KEY`: Encryption key for credentials.yml.enc

### 4. Database Setup
Create the database, run migrations, and seed it with sample data:
```bash
rails db:create
rails db:migrate
rails db:seed
```

The seed will populate:
- 5+ sample products with variants
- 3+ categories
- Test user accounts (regular + admin)
- Sample orders and reviews

### 5. Run the Server
Start the Rails development server:
```bash
rails server
```

Then open [http://localhost:3000](http://localhost:3000) in your browser.

### 6. Set Up an Admin Account (First Time)
```bash
rails console
user = User.create(
  email: 'admin@example.com',
  password: 'SecurePassword123!',
  password_confirmation: 'SecurePassword123!',
  admin: true
)
```

## 💳 Testing Payment Methods

The application provides three sandbox payment methods for testing:

### 1. Test Card
- **Card Number**: 4242 4242 4242 4242
- **Expiry**: Any future date (e.g., 12/25)
- **CVC**: Any 3-digit number
- **Auto-completes** for instant demo feedback

### 2. Cash on Delivery (COD)
- Order placed with COD is marked as **Pending**
- Admin can update status to **Paid** when cash is collected
- Payments tracked manually

### 3. Manual Confirmation
- Default payment method
- Orders require explicit admin approval
- Useful for bank transfer or custom payment arrangements

## 📊 Admin Features

### Dashboard
- **Revenue Stats**: Total revenue, daily/weekly trends
- **Order Metrics**: Total orders, pending, paid, shipped
- **User Count**: Active users, new registrations
- **Unread Messages**: Quick access to customer inquiries
- **Quick Links**: Fast navigation to products, categories, orders

### Product Management
- **Create/Edit** products with multiple variants (sizes, colors, SKUs)
- **Stock Management**: Add/remove stock per variant
- **Pricing**: Set base prices and variant-specific pricing
- **Bulk Operations**: Import products via CSV (future feature)

### Order Management
- **Status Updates**: Pending → Paid → Processing → Shipped → Delivered
- **Email Notifications**: Automatic alerts sent on status change
- **Invoice Download**: Generate and download PDF invoices
- **Return Requests**: Process and track customer returns

### Category Management
- **Create/Edit** categories with descriptions
- **Assign Products**: Bulk assign products to categories
- **Reorder**: Change category display order

## 📧 Email & Notifications

The application uses **Letter Opener** (development) and **Action Mailer** for emails:

- **Order Confirmation**: Sent immediately after successful checkout
- **Payment Received**: Sent when payment is confirmed
- **Order Shipped**: Sent when order status changes to Shipped
- **Custom Notifications**: Admins can send messages to users

### Development Email Preview
Emails are previewed in [http://localhost:3000/letter_opener](http://localhost:3000/letter_opener) during development.

## 📄 Invoice Management

Invoices are automatically generated using **Prawn** gem:

- **PDF Download**: Users can download invoices from order details
- **Auto-Generated**: Includes itemized list, tax, shipping, totals
- **Email Attached**: Optional invoice attachment to order confirmation email (configurable)
- **Admin Access**: View all invoices from admin dashboard

## � Tech Stack

### Backend
- **Rails 8.1.2**: Modern Ruby on Rails framework with Turbo Rails and Stimulus JS integrated
- **PostgreSQL 14**: Relational database with row-level locking for concurrent checkout safety
- **Devise**: User authentication and authorization
- **Pundit**: Authorization policy framework (optional, can be enhanced)

### Frontend
- **Bootstrap 5**: Responsive CSS framework
- **Bootstrap Icons**: Icon library for UI enhancements
- **Turbo Rails**: Real-time UI updates without full page reloads
- **Stimulus JS**: Lightweight JavaScript framework for interactivity
- **ERB Templates**: Server-side templating

### Key Gems
- **Stripe 18.4**: Payment processing (sandbox mode)
- **Prawn 2.5**: PDF generation for invoices
- **Prawn-table 0.2.2**: PDF table formatting
- **PgSearch 2.3**: Full-text search powered by PostgreSQL
- **Discard 1.4**: Soft deletes for models
- **Pagy 8.3**: Lightweight pagination
- **Letter Opener 1.10**: Email preview in development
- **Turbo Rails 2.x**: Reactive UI components
- **Stimulus Rails 1.3**: JavaScript framework integration
- **OmniAuth**: Social authentication (Google, GitHub)
- **Brakeman**: Security vulnerability scanning
- **RuboCop**: Code style enforcement

### Database Features
- **Row-Level Locking** (Variant.lock): Prevents stock race conditions during checkout
- **Transactions**: ACID-compliant order processing with atomic operations
- **Soft Deletes**: Models marked as discarded without permanent deletion
- **Full-Text Search**: PostgreSQL-powered product search

## 📂 Key Project Structure

*   **`app/models`**: Core business logic (User, Product, Order, Cart, etc.)
*   **`app/controllers`**: Request handlers with authorization (products, orders, admin)
*   **`app/services`**: Business logic services (OrderService, OrderInvoice)
*   **`app/concerns`**: Reusable controller concerns (AdminAuthenticatable)
*   **`app/mailers`**: Email notification templates (OrderMailer)
*   **`app/views`**: ERB templates with Bootstrap 5 styling
*   **`config/routes.rb`**: RESTful and admin namespace routes
*   **`db/migrations`**: Database schema changes (versioned)

## 🔒 Security Features

- **Authentication**: Devise with password encryption
- **Authorization**: Role-based access control (admin flag on User)
- **CSRF Protection**: Rails default CSRF tokens on all forms
- **Data Encryption**: Sensitive fields encrypted at rest
- **Transaction Safety**: Row locking prevents concurrent stock updates
- **Input Validation**: Strong parameters and model validations
- **Security Scanning**: Brakeman checks for vulnerabilities
- **Dependency Auditing**: Bundler-audit for gem vulnerabilities

## 📝 License

This project is open-source and available under the standard MIT license.
