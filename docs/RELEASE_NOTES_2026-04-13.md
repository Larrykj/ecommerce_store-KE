# Release Notes - 2026-04-13

## Release Summary

This release focuses on launch readiness: checkout stability, admin UX polish, API contract consistency, security hardening, and deployment documentation.

## Highlights

- Checkout reliability improved for inventory race conditions and payment verification edge cases.
- Admin usability improved with responsive navigation and clearer form validation feedback.
- API v1 standardized around:
  - error envelope (`error.code`, `error.message`)
  - pagination metadata (`meta.pagination`)
- API contract smoke tests added to CI (`test/controllers/api/v1/contracts_test.rb`).
- Security posture tightened:
  - OmniAuth request methods limited to `POST`
  - CORS made environment-aware (production-only origin in production)
  - secret-like values removed from `env.example`

## User-Facing Impact

- Clearer order status messaging, including backorder scenarios.
- Better mobile behavior in admin views.
- More consistent API behavior for mobile/web clients.

## Operational Impact

- New docs:
  - `docs/API_CONTRACT.md`
  - `docs/DEPLOY_RUNBOOK.md`
  - `docs/GO_NO_GO.md`
- Existing launch docs updated with cross-links and SOP guidance.

## Validation Snapshot

- Rails tests: passing
- API contract tests: passing
- RuboCop (Ruby files): passing

## Known Non-Blocking Notes

- Dependency-level boot deprecation warning (`ActiveSupport::Configurable`) still present.
- CSP currently allows inline styles to support current UI; consider tightening in follow-up hardening.
