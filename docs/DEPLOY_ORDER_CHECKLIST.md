# Deploy Order Checklist (Release Day)

Follow this order exactly to reduce launch risk.

## T-24h to T-2h (Preparation)

- [ ] Confirm go/no-go in `docs/GO_NO_GO.md`
- [ ] Confirm env vars set in production secret manager
- [ ] Verify Stripe live keys + webhook secret
- [ ] Verify OAuth callback URLs in Google/GitHub
- [ ] Confirm DB backup/snapshot policy is active
- [ ] Confirm on-call owner for first launch hour

## T-30m (Preflight)

- [ ] Pull latest release branch
- [ ] Run:
  - [ ] `bundle exec rubocop`
  - [ ] `bundle exec rails test`
- [ ] Confirm no pending migrations conflicts
- [ ] Announce deploy window

## T-0 (Deploy)

- [ ] Build and deploy app image/release
- [ ] Run `bundle exec rails db:migrate`
- [ ] Restart app processes
- [ ] Verify app boot and health endpoint/root route

## T+5m (Smoke Tests)

- [ ] Storefront loads
- [ ] Login/signup works
- [ ] Product browse/detail works
- [ ] Cart + checkout happy path works
- [ ] Admin login and key forms work
- [ ] API checks:
  - [ ] `/api/v1/products` returns `meta.pagination`
  - [ ] `/api/v1/orders` unauthorized returns error envelope
  - [ ] `/api/v1/orders` authorized returns paginated data

## T+15m to T+60m (Stabilization)

- [ ] Monitor 5xx rate and latency
- [ ] Monitor checkout/payment errors
- [ ] Monitor webhook failures
- [ ] Monitor job queue and mailer errors

## Rollback Trigger (If Needed)

Rollback if any of the following persist >10 minutes:

- checkout/payment failures above acceptable threshold
- sustained elevated 5xx errors
- critical admin functionality unavailable

Rollback steps:

- [ ] Revert to previous release image/version
- [ ] Restart processes
- [ ] Re-run smoke checklist
- [ ] Open incident log and decide forward-fix
