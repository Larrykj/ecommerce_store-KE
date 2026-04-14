# E-Commerce Store (Kenya Edition) 🇰🇪

Build your online store with confidence. A **production-ready e-commerce platform** tailored for the African market, built with modern Rails technology and designed for seamless scaling.

## Operational Docs

- `docs/LAUNCH_READINESS.md` - security, auth, throttling, and pre-launch checks
- `docs/AI_AND_SUPPORT.md` - AI/chat and support flow refinements
- `docs/MOBILE_WRAPPER_ANDROID.md` - Android wrapper build stabilization and packaging
- `docs/API_CONTRACT.md` - API error envelope, pagination meta, and integration contract
- `docs/DEPLOY_RUNBOOK.md` - production deploy, rollback, and smoke-check checklist
- `docs/GO_NO_GO.md` - final launch gate status and go/no-go checklist
- `docs/DEPLOY_ORDER_CHECKLIST.md` - release-day deploy sequence and rollback triggers
- `docs/RELEASE_NOTES_2026-04-13.md` - release summary for stakeholders
- `docs/COMMIT_PLAN.md` - recommended commit grouping and sequencing
- `docs/LAUNCH_COMMANDS.md` - copy/paste preflight, deploy, and smoke-test commands

This is a complete, battle-tested e-commerce solution featuring customer storefronts, powerful admin dashboards, safe payment processing, and enterprise-grade security—ready to handle real business workflows from day one.

---

## ✨ Why This Application?

**🚀 Production Ready**: Complete CRUD operations, admin controls, and real-world features. Not a toy project.

**💰 Payment Solutions**: Multiple payment modes (Stripe, Cash on Delivery, manual confirmations) for diverse market needs.

**🔒 Stock-Safe**: Concurrent checkout with database-level row locking prevents overselling—the #1 e-commerce failure.

**📊 Admin Insights**: Real-time dashboards, revenue tracking, order management, and inventory control.

**🌍 Africa-First**: Prices in Kenyan Shillings, easy localization for other markets, soft-delete safety for compliance.

**⚡ Modern Stack**: Rails 8, Turbo Rails, PostgreSQL, Docker-ready, CI/CD integrated.

---

## 🚀 Features

### Core Shopping Experience

- **🛒 Smart Product Discovery**: Full-text search, advanced filtering, price ranges, stock status visibility. Customers find what they need fast.
- **🛍️ Frictionless Cart**: Real-time validation prevents checkout surprises. Persistent carts across sessions. Turbo-powered instant updates—no page reloads.
- **💳 Safe Checkout Flow**:
  - Multiple payment methods built-in (Stripe, COD, manual approvals).
  - **Race-condition proof**: Database transactions with row locking—safe even under high traffic.
  - PDF invoices generated instantly, email confirmations automatic.
- **⭐ Social Proof**: Product reviews with ratings, helpful voting, customer feedback directly on listings.
- **❤️ Smart Wishlist**: One-click saving, price drop notifications, easy bulk checkout.
- **🔄 Product Comparison**: Side-by-side feature comparisons reduce refunds and returns.

### 👨‍💼 Admin & Management (Back-Office Power)

- **📊 Intelligent Dashboard**:
  - Revenue metrics, order trends, user growth in one glance.
  - Unread customer messages, low-stock alerts, priority actions.
  - Export-ready analytics for reporting.
- **🎁 Product Ecosystem**:
  - Variants (sizes, colors, SKUs) baked in—no workarounds.
  - Soft deletes for safe corrections and audit trails.
  - Bulk category management and reorganization.
- **📦 Order Command Center**:
  - Visual status pipeline: Pending → Paid → Processing → Shipped → Delivered.
  - Automatic email alerts on each transition.
  - Return & refund request management built-in.
  - Instant PDF invoice downloads for accounting.
- **🚀 Customer Relationship**:
  - Gift card management and redemption tracking.
  - Promo codes with expiration and usage limits.
  - Contact message tracking (read/unread).

### 🔐 Built-In Security & Compliance

- **Row-Level Locking**: Database-level stock protection—no overselling possible.
- **Transaction Safety**: ACID compliance on all financial operations.
- **Encryption at Rest**: Sensitive customer data (SSN, payment info) encrypted.
- **CSRF Protection**: Every form protected against cross-site attacks.
- **Audit Trails**: Soft deletes mean you never lose data—just mark it deleted.
- **Password Security**: Bcrypt hashing, optional 2FA via Devise.

### 💎 Advanced Features

- **🔍 Enterprise Search**: PostgreSQL full-text indexing. Find products in milliseconds, even with 100k+ SKUs.
- **📄 Lightweight Pagination**: Pagy gem serves 10,000+ products without slowdown.
- **💸 Revenue Optimization**: Promo codes, tiered shipping, gift card ecosystem.
- **💌 Automated Notifications**:
  - Order confirmation + tracking links
  - Payment received alerts
  - Shipment notifications with tracking
  - Custom admin-to-customer messages
- **🌍 Localization Ready**:
  - Prices in Kenyan Shillings (KSh) with proper formatting.
  - Easy multi-currency support for regional expansion.
  - Inventory management per region/warehouse.
- **📱 Mobile-First Design**: Bootstrap 5—looks perfect on phones, tablets, desktops.
- **⚡ Real-Time Reactivity**: Turbo Rails updates cart/wishlist without page reloads. Subscribe to status changes live.
- **🔗 Social Login**: Google, GitHub authentication options built-in.

## 🛠️ Prerequisites

Ensure you have the following installed:

- Ruby 3.3+
- Rails 8.1.2+
- PostgreSQL 14+ (or SQLite3 for development)
- Node.js 20+

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

- **Dashboard**: Navigate to [http://localhost:3000/admin](http://localhost:3000/admin)
- **Protected Actions**: All admin-only routes are protected by `AdminAuthenticatable` concern
- **Redirect**: Non-admin users accessing admin areas are redirected to home
- **Authorization Helpers**: User model provides `can_manage_products?`, `can_manage_categories?`, `can_manage_orders?`, etc.

## � Quick Start (5 Minutes)

Get the store running locally in under 5 minutes:

### Step 1: Prerequisites

- **Ruby 3.3+**
- **Rails 8.1.2+**
- **PostgreSQL 14+** (or SQLite3 for quick demo)
- **Node.js 20+**

### Step 2: Clone & Install

```bash
git clone https://github.com/Larrykj/ecommerce_store-KE.git
cd ecommerce_store-KE
bundle install
```

### Step 3: Configure Environment

```bash
cp env.example .env
# Edit .env with your settings (optional for development)
```

### Step 4: Database Setup

```bash
rails db:create
rails db:migrate
rails db:seed
```

**Seeded with**: 5+ products, categories, test users (regular + admin), sample orders.

### Step 5: Launch

```bash
rails server
```

Open [http://localhost:3000](http://localhost:3000) → **Store is live!**

### Step 6: Admin Access (First Time Only)

```bash
rails console
user = User.create!(
  email: 'admin@store.test',
  password: 'SecurePassword123!',
  admin: true
)
```

Then sign in and visit [http://localhost:3000/admin](http://localhost:3000/admin)

## 💳 Payment Testing & Modes

### Three Payment Methods Built-In

**1. Stripe Test Card** (Instant Processing)

- Card: `4242 4242 4242 4242`
- Expiry: Any future date (e.g., 12/25)
- CVC: Any 3 digits
- **Result**: Order marked "Paid" instantly. Receipt emailed.

**2. Cash on Delivery (COD)** (Common in Africa)

- Customer places order → Status: "Pending"
- Order summary visible in customer account
- Admin receives notification
- Admin confirms payment received → Status: "Paid"
- Perfect for locations without digital payment infrastructure

**3. Manual Confirmation** (Flexible)

- Order created → Status: "Pending"
- Admin manually reviews & approves
- Ideal for bank transfers, corporate orders, or custom arrangements

### Admin Payment Management

- View all pending payments in dashboard
- Batch status updates with bulk operations
- Email customers automatically on payment received
- Full audit trail of who updated payment when

## 📊 Admin Dashboard Walkthrough

Sign in at `/admin` to access:

- **💰 Revenue Graph**: Daily/weekly revenue trends at a glance
- **📈 Order Metrics**: Live counts (total, pending, paid, shipped, delivered)
- **👥 Customer Insights**: New registrations, active users, repeat buyers
- **📬 Message Center**: Unread customer inquiries with one-click response
- **⚠️ Quick Alerts**: Low-stock warnings, pending payments, new reviews

### Inventory Management

- Real-time stock levels per variant (size/color/SKU)
- Automatic low-stock warnings
- Reorder recommendations based on sales velocity
- Stock history log (who adjusted, when, why)

### Order Command Center

- Visual order status board (Kanban style)
- Bulk actions (mark 10 orders as "Shipped" in seconds)
- Change statuses with automatic customer notifications
- Download invoices for accounting
- Print packing slips

### Customer Communication

- Send promotional emails
- Notify on order updates
- Contact form message management
- Customer feedback/review moderation

### Reporting

- Export orders to CSV/PDF
- Revenue reports by period
- Top products by sales
- Customer acquisition cost tracking (basic)

## 📧 Email & Invoices

### Automated Notifications

- **Order Confirmation**: Sent immediately with items, totals, tracking link
- **Payment Alerts**: Notification when payment received
- **Shipment Updates**: Track order progress from warehouse to doorstep
- **Custom Messages**: Admins can send promotional/informational emails

### PDF Invoices (Prawn)

- **Auto-Generated**: Itemized, taxes, shipping, totals
- **Customer Download**: Available in order page
- **Professional Formatting**: Ready for accounting and audits
- **Email Integration**: Attach to confirmation email (optional)

**Dev Mode**: Preview all emails at [http://localhost:3000/letter_opener](http://localhost:3000/letter_opener)

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

- **`app/models`**: Core business logic (User, Product, Order, Cart, etc.)
- **`app/controllers`**: Request handlers with authorization (products, orders, admin)
- **`app/services`**: Business logic services (OrderService, OrderInvoice)
- **`app/concerns`**: Reusable controller concerns (AdminAuthenticatable)
- **`app/mailers`**: Email notification templates (OrderMailer)
- **`app/views`**: ERB templates with Bootstrap 5 styling
- **`config/routes.rb`**: RESTful and admin namespace routes
- **`db/migrations`**: Database schema changes (versioned)

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
