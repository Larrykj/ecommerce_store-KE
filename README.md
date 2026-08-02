# E-Commerce Store KE 🇰🇪

A production-ready, mobile-friendly e-commerce platform for businesses that want to launch and scale online sales quickly.

[Live Demo](https://ecommerce-store-ke-api.onrender.com)

---

## 🚀 1-Minute Overview

**E-Commerce Store KE** provides a complete commerce foundation with:

- A polished, responsive storefront
- Secure checkout with flexible payment workflows
- Full admin dashboard for products, orders, and operations
- Rails + PostgreSQL backend with deployment-ready structure
- Optional Flutter Android wrapper for mobile app distribution

---

## ✨ Core Features

### Storefront Experience
- Product browsing, search, and filtering
- Product categories and detail pages
- Cart with persistent session behavior
- Wishlist, comparison, and reviews
- Fully responsive UI (mobile/tablet/desktop)

### Checkout & Orders
- Secure checkout flow
- Multiple payment method support
- Order confirmations and status updates
- PDF invoice generation for customers/admins
- Customer order tracking

### Admin Operations
- Product, category, and inventory management
- Order processing and status pipeline
- Customer communication tooling
- Revenue and performance visibility
- Low-stock alerts and operational insights

---

## 🧱 Tech Stack

### Backend
- Ruby on Rails
- PostgreSQL
- Devise (authentication)
- Pundit (authorization)
- Prawn (PDF invoices)
- Pagy (pagination)
- Discard (soft deletes)
- Stripe-ready payment integration

### Frontend
- ERB templates
- Bootstrap 5
- Turbo Rails
- Stimulus JS
- JavaScript + CSS

### Mobile
- Flutter Android wrapper
- WebView shell
- Play Store-ready packaging structure

---

## 📸 Screenshots

- **Homepage**  
  <img width="1336" height="595" alt="Homepage screenshot" src="https://github.com/user-attachments/assets/be3c4b34-8035-48b2-a032-d128bdff658c" />

- **Product Listing**  
  <img width="1331" height="582" alt="Product listing screenshot" src="https://github.com/user-attachments/assets/aec85625-dbdb-4449-8fe2-68014bc59b65" />

- **Product Details**  
  <img width="521" height="585" alt="Product details screenshot" src="https://github.com/user-attachments/assets/a1deef3c-9f62-46f9-95b9-99fa6cb2c471" />

- **Cart & Checkout**  
  <img width="907" height="595" alt="Cart and checkout screenshot" src="https://github.com/user-attachments/assets/77e391a0-4699-49a0-a540-7038907ee76f" />

- **Admin Dashboard**  
  <img width="1365" height="602" alt="Admin dashboard screenshot" src="https://github.com/user-attachments/assets/827bbb4a-5d93-4dd2-9a00-286a8395bbc2" />

- **Mobile View**  
  <img width="1362" height="601" alt="Mobile view screenshot" src="https://github.com/user-attachments/assets/ccfc78c9-d083-41d4-bf60-8411926672de" />

---

## ⚙️ Quick Start

### Prerequisites
- Ruby 3.3+
- Rails 8.1.2+
- PostgreSQL 14+ (or SQLite3 for development)
- Node.js 20+

### Installation

```bash
git clone https://github.com/Larrykj/ecommerce_store-ke.git
cd ecommerce_store-ke
bundle install
```

### Environment Setup

```bash
cp env.example .env
# Edit .env with your local settings
```

### Database Setup

```bash
rails db:create
rails db:migrate
rails db:seed
```

### Run

```bash
rails server
```

Open: `http://localhost:3000`

---

## 🔐 Admin Access

Create an admin user from Rails console:

```bash
rails console
```

```ruby
User.create!(
  email: "admin@store.test",
  password: "SecurePassword123!",
  admin: true
)
```

Then visit: `http://localhost:3000/admin`

---

## 💳 Payment Workflows

Supports multiple checkout styles for different market realities:

- Stripe test payments
- Cash on Delivery
- Manual confirmation flows

---

## 📱 Android Wrapper

Flutter wrapper location: `ecommerce_android_wrapper/`

### Build Requirements
- Flutter 3.12+
- Android SDK API 21+
- Target SDK API 35

### Run Wrapper

```bash
cd ecommerce_android_wrapper
flutter pub get
flutter run
```

Release/signing guide:  
`ecommerce_android_wrapper/SIGNING_INSTRUCTIONS.md`

---

## 🗂️ Project Structure

- `app/models` — business domain logic
- `app/controllers` — request/response handling
- `app/services` — service-layer workflows
- `app/concerns` — reusable modules
- `app/mailers` — notifications
- `app/views` — storefront/admin UI
- `config/routes.rb` — routing
- `db/migrations` — schema changes
- `docs/` — launch and deployment documents

---

## 📚 Documentation

- `docs/LAUNCH_READINESS.md`
- `docs/AI_AND_SUPPORT.md`
- `docs/MOBILE_WRAPPER_ANDROID.md`
- `docs/API_CONTRACT.md`
- `docs/DEPLOY_RUNBOOK.md`
- `docs/GO_NO_GO.md`
- `docs/DEPLOY_ORDER_CHECKLIST.md`
- `docs/RELEASE_NOTES_2026-04-13.md`
- `docs/COMMIT_PLAN.md`
- `docs/LAUNCH_COMMANDS.md`

---

## 🛡️ Security & Reliability

- Encrypted authentication flows
- Role-based authorization controls
- CSRF protection
- Transaction-safe order processing
- Row-level locking to reduce overselling
- Validation and security scanning support
- Soft-delete strategy for safer recovery

---

## 🧭 Roadmap

- More storefront and conversion-focused screenshots
- SEO landing page enhancements
- Customer testimonial section
- Blog/updates module
- Expanded payment integrations
- Multilingual support

---

## 🤝 Contributing

Contributions and feedback are welcome.

If you want to adapt this platform for your business or client projects, feel free to open an issue.

---

## 📄 License

MIT License
