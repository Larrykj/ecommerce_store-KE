# Commit Grouping Plan

Use this sequence to create clean, reviewable commits from the current working tree.

## Commit 1 - Checkout Stability and Core Tests

- `app/controllers/checkouts_controller.rb`
- `app/models/order.rb`
- `test/integration/checkout_flow_test.rb`
- `test/fixtures/users.yml`

Message idea:
- `Harden checkout flow for inventory races and stabilize integration tests`

## Commit 2 - Admin UX Improvements

- `app/views/layouts/admin.html.erb`
- `app/views/admin/products/index.html.erb`
- `app/views/admin/products/_form.html.erb`
- `app/views/admin/categories/_form.html.erb`
- `app/views/admin/promo_codes/_form.html.erb`
- `app/views/admin/shipping_methods/_form.html.erb`
- `app/views/orders/show.html.erb`

Message idea:
- `Improve admin responsiveness and form validation UX`

## Commit 3 - API Contract and Security Hardening

- `app/controllers/api/v1/base_controller.rb`
- `app/controllers/api/v1/products_controller.rb`
- `app/controllers/api/v1/categories_controller.rb`
- `app/controllers/api/v1/orders_controller.rb`
- `app/controllers/api/v1/payments_controller.rb`
- `app/controllers/api/v1/ai_controller.rb`
- `config/initializers/devise.rb`
- `config/initializers/cors.rb`
- `env.example`

Message idea:
- `Standardize API responses and tighten auth/CORS security`

## Commit 4 - API Contract Tests and Release Docs

- `test/controllers/api/v1/contracts_test.rb`
- `docs/API_CONTRACT.md`
- `docs/DEPLOY_RUNBOOK.md`
- `docs/GO_NO_GO.md`
- `docs/RELEASE_NOTES_2026-04-13.md`
- `docs/COMMIT_PLAN.md`
- `README.md`
- `docs/LAUNCH_READINESS.md`

Message idea:
- `Add API contract tests and launch handoff documentation`

## Pre-Commit Checklist (Each Commit)

- Run targeted tests for changed area.
- Run full suite before final push:
  - `bundle exec rails test`
- Run RuboCop for changed Ruby files.
