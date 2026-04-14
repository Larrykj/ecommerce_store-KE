# Deploy Runbook (Production)

This runbook is a practical checklist for production deploys and rollbacks.
Use it as the single source of truth when releasing.

## 1) Required Environment Variables

Set these in your hosting platform (not in repo files):

- `DATABASE_URL`
- `SECRET_KEY_BASE`
- `RAILS_ENV=production`
- `RAILS_LOG_TO_STDOUT=true`
- `RAILS_SERVE_STATIC_FILES=true`
- `ACTIVE_RECORD_PRIMARY_KEY`
- `ACTIVE_RECORD_DETERMINISTIC_KEY`
- `ACTIVE_RECORD_KEY_DERIVATION_SALT`
- `LOCKBOX_MASTER_KEY`
- `STRIPE_SECRET_KEY`
- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_CURRENCY` (for your live setup, e.g. `kes`/`usd`)
- `OPENAI_API_KEY` (if AI endpoints are enabled)
- OAuth keys if social login is enabled:
  - `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
  - `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`

Reference template: `env.example`

## 2) Pre-Deploy Checks

Run locally (or in CI) before deploy:

```bash
bundle exec rubocop
bundle exec rails test
```

Security sanity:

- Ensure no secrets are committed.
- Confirm `config/master.key` is not committed and host has correct `RAILS_MASTER_KEY` if needed.
- Verify Stripe is using live keys in production.

## 3) Deploy Sequence

1. Pull latest main/release branch.
2. Build and release app image.
3. Run migrations:

```bash
bundle exec rails db:migrate
```

4. Restart web processes.
5. Run post-deploy smoke checks (section 5).

## 4) Docker-Based Deploy (Reference)

Build image:

```bash
docker build -t ecommerce-rails:release .
```

Run (example only; inject real env vars from secret manager):

```bash
docker run -d \
  --name ecommerce-rails \
  -p 80:80 \
  -e RAILS_ENV=production \
  -e DATABASE_URL=... \
  -e SECRET_KEY_BASE=... \
  ecommerce-rails:release
```

Then run migrations in container:

```bash
docker exec -it ecommerce-rails bundle exec rails db:migrate
```

## 5) Post-Deploy Smoke Checklist

Web:

- `GET /` returns 200.
- Sign in and sign up work.
- Product listing and product detail pages load.
- Cart add/update/remove works.

Checkout:

- Create a test order with a safe payment path (test mode/staging).
- Verify order appears in `/orders` and admin `/admin/orders`.

Admin:

- `/admin` loads for admin account.
- Product create/edit saves successfully.
- Promo/shipping forms validate correctly.

API:

- `GET /api/v1/products` returns `meta.pagination`.
- `GET /api/v1/orders` without token returns standardized `error` envelope.
- `GET /api/v1/orders` with valid token returns paginated data.

## 6) Rollback Procedure

If release is unhealthy:

1. Roll back app image/version to previous known-good release.
2. Restart app processes.
3. If a migration caused breakage:
   - Prefer forward-fix migration if possible.
   - Only run rollback migration if it is explicitly safe and tested.
4. Re-run smoke checklist.

## 7) Observability and Alerts (Minimum)

- Track 5xx rate, response latency, and error logs.
- Monitor checkout failures and webhook errors.
- Monitor background jobs and mail delivery queue.
- Set alert thresholds for:
  - sustained 5xx spikes,
  - failed payment verification spikes,
  - DB connection saturation.

## 8) Ownership Notes

- Product owner approval required before production deploy.
- Keep a short release note per deploy (date, changes, rollback target).
