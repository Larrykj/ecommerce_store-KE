# E-Commerce Store KE 🇰🇪

A modern, mobile-friendly e-commerce platform built for businesses that want to sell online with confidence.

It combines a polished storefront, admin tools, secure checkout flows, product management, and deployment-ready infrastructure — making it a strong foundation for local businesses, developers, and agencies building real commerce solutions.

Live Demo: https://ecommerce-store-ke-api.onrender.com


## Why This Project?

- Built for real online selling, not just demos
- Mobile-first storefront experience
- Admin tools for products, orders, customers, and reporting
- Flexible payment workflows for different business needs
- Ready to customize, brand, and deploy
- Includes an Android wrapper for mobile distribution

---

## ✨ Features

A complete commerce foundation for real-world selling — built to help businesses launch faster, manage orders easily, and deliver a polished shopping experience.

### Storefront

- Product browsing with search and filtering
- Product categories and product detail pages
- Shopping cart with persistent session behavior
- Wishlist, comparisons, and customer reviews
- Responsive design for phones, tablets, and desktops

### Checkout & Orders

- Secure checkout flow
- Multiple payment options support
- Order confirmations and status updates
- PDF invoices for customers and admins
- Customer order tracking

### Admin Dashboard

- Product, category, and inventory management
- Order management and status pipeline
- Customer communication tools
- Revenue and performance visibility
- Low-stock alerts and operational insights

### Platform Capabilities

- Rails-based backend
- PostgreSQL-powered data layer
- Turbo-powered reactive interactions
- Authentication and authorization support
- Docker-ready development/deployment setup
- Android WebView wrapper for mobile packaging

---

## Who Is This For?

- Small and medium businesses
- Entrepreneurs launching an online store
- Agencies building e-commerce projects for clients
- Developers looking for a solid Rails commerce base
- Anyone who wants a customizable store foundation

---

## Live Demo

- Production site: https://ecommerce-rails-app.onrender.com
- Android wrapper: `ecommerce_android_wrapper/`

---

## Screenshots

- Homepage  <img width="1336" height="595" alt="Screenshot 2026-08-01 115510" src="https://github.com/user-attachments/assets/be3c4b34-8035-48b2-a032-d128bdff658c" />

- Product listing page  <img width="1331" height="582" alt="Screenshot 2026-08-01 115712" src="https://github.com/user-attachments/assets/aec85625-dbdb-4449-8fe2-68014bc59b65" />

- Product details page  <img width="521" height="585" alt="Screenshot 2026-08-01 115843" src="https://github.com/user-attachments/assets/a1deef3c-9f62-46f9-95b9-99fa6cb2c471" />

- Cart and checkout  <img width="907" height="595" alt="Screenshot 2026-08-01 115954" src="https://github.com/user-attachments/assets/77e391a0-4699-49a0-a540-7038907ee76f" />

- Admin dashboard  <img width="1365" height="602" alt="Screenshot 2026-08-01 120120" src="https://github.com/user-attachments/assets/827bbb4a-5d93-4dd2-9a00-286a8395bbc2" />

- Mobile view  <img width="1362" height="601" alt="Screenshot 2026-08-01 120242" src="https://github.com/user-attachments/assets/ccfc78c9-d083-41d4-bf60-8411926672de" />




## Tech Stack

### Backend

- Ruby on Rails
- PostgreSQL
- Devise for authentication
- Pundit for authorization
- Prawn for PDF invoices
- Pagy for pagination
- Discard for soft deletes
- Stripe integration support

### Frontend

- HTML / ERB templates
- CSS
- JavaScript
- Bootstrap 5
- Turbo Rails
- Stimulus JS

### Mobile Wrapper

- Flutter
- Android WebView shell
- Play Store-ready packaging structure

---

## Quick Start

### Prerequisites

- Ruby 3.3+
- Rails 8.1.2+
- PostgreSQL 14+ or SQLite3 for development
- Node.js 20+

### Install

git clone https://github.com/Larrykj/ecommerce_store-ke.git
cd ecommerce_store-ke
bundle install

**Environment Setup**
cp env.example .env
# **Edit .env if needed for your local configuration**

**Database Setup**
rails db:create
rails db:migrate
rails db:seed

**Run The App**
rails server

**Admin Access**
This app uses an admin flag on the User model.

**Create an Admin User**
rails console
user = User.create!(
  email: 'admin@store.test',
  password: 'SecurePassword123!',
  admin: true
)

Then sign in and visit:

http://localhost:3000/admin
**Admin Capabilities**
Manage products and categories
Handle orders and order statuses
Review customer messages
Monitor inventory and low-stock alerts
Access operational dashboards
Payment Methods

**The application supports multiple checkout flows, including:
**
Stripe test payments
Cash on Delivery
Manual confirmation workflows
This gives flexibility for businesses operating in markets with different payment preferences.

**Android Wrapper**
The repository includes a Flutter-based Android wrapper for packaging the store as a mobile app.

Wrapper Location
ecommerce_android_wrapper/
**Build Requirements**
Flutter 3.12+
Android SDK API 21+
Android SDK API 35 target
**Quick Start**
cd ecommerce_android_wrapper
flutter pub get
flutter run
For release packaging, see:
ecommerce_android_wrapper/SIGNING_INSTRUCTIONS.md

**Project Structure**
app/models — core business logic
app/controllers — request handling
app/services — application services
app/concerns — reusable controller behavior
app/mailers — email notifications
app/views — storefront and admin UI
config/routes.rb — application routes
db/migrations — database schema changes
docs/ — launch and deployment documentation

**Documentation**
Useful operational docs included in this repository:
docs/LAUNCH_READINESS.md
docs/AI_AND_SUPPORT.md
docs/MOBILE_WRAPPER_ANDROID.md
docs/API_CONTRACT.md
docs/DEPLOY_RUNBOOK.md
docs/GO_NO_GO.md
docs/DEPLOY_ORDER_CHECKLIST.md
docs/RELEASE_NOTES_2026-04-13.md
docs/COMMIT_PLAN.md
docs/LAUNCH_COMMANDS.md
Security & Reliability
Password encryption and authentication
Authorization for admin actions
CSRF protection
Transaction-safe order handling
Row-level locking to reduce overselling risk
Validation and security scanning support
Soft deletes for safer data handling
**Roadmap Ideas**
Potential next improvements:

Add more storefront screenshots
Add a hosted pricing page
Add customer testimonials
Add SEO landing page copy
Add blog or updates section
Add more payment integrations
Add multilingual support
**Contributing**
Contributions, ideas, and feedback are welcome.

If you want to customize this platform for your business or client project, feel free to open an issue or reach out.

**License**
This project is open-source and available under the MIT License.
