# API Contract (v1)

This document defines the baseline response contract for `api/v1` endpoints.
It is intended for web, mobile, and integration clients.

## 1) Error Envelope

When an endpoint returns an error, the response follows this shape:

```json
{
  "error": {
    "code": "string_identifier",
    "message": "Human-readable message",
    "details": {}
  }
}
```

Notes:

- `details` is optional and may be omitted.
- `code` is stable and should be preferred by clients for branching logic.
- `message` is intended for logs or direct user feedback.

Common examples:

- Unauthorized:
  - HTTP `401`
  - `error.code = "unauthorized"`
- Missing record:
  - HTTP `404`
  - `error.code = "product_not_found" | "category_not_found" | "order_not_found"`
- Validation/request issues:
  - HTTP `422`
  - `error.code = "invalid_payment_request"` (payments), etc.

## 2) Pagination Meta

List-style endpoints include pagination metadata in `meta.pagination`.

```json
{
  "meta": {
    "pagination": {
      "total": 120,
      "limit": 20,
      "offset": 40,
      "current_page": 3,
      "total_pages": 6
    }
  }
}
```

Field definitions:

- `total`: total items matching the query.
- `limit`: number of items requested per page.
- `offset`: zero-based starting index.
- `current_page`: computed as `(offset / limit) + 1`.
- `total_pages`: computed as `ceil(total / limit)`.

## 3) Endpoints with Pagination Meta

Current v1 endpoints returning `meta.pagination`:

- `GET /api/v1/products`
- `GET /api/v1/categories/:id` (for embedded products list)
- `GET /api/v1/orders` (authenticated)
- `GET /api/v1/categories` (includes `total` and pagination metadata for consistency)

## 4) Input Guardrails

For paginated endpoints:

- `limit` is clamped to a safe range (`1..50` by default).
- negative `offset` values are normalized to `0`.

This prevents abusive or accidental heavy requests and creates predictable client behavior.

## 5) Contract Coverage in Tests

Contract smoke tests live at:

- `test/controllers/api/v1/contracts_test.rb`

These tests verify:

- standardized unauthorized error envelope,
- presence and shape of pagination metadata,
- basic response shape consistency on key endpoints.
