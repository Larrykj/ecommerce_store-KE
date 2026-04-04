# AI and Customer Support Refinements

## AI Chat Endpoint

- Path: `POST /api/v1/ai/chat`
- Validation:
  - empty message -> 422
  - messages longer than 1000 chars -> 422
- Caching:
  - request content hashed with SHA256
  - cached response for 24h
- 429 quota/rate-limit from OpenAI is converted to a user-readable assistant reply.

## Recommendations Endpoint

- Path: `POST /api/v1/ai/recommendations`
- Supports optional auth via bearer token.
- If authenticated:
  - uses browsing/view behavior for personalized product recommendations.
- If anonymous:
  - returns high-rated and high-feedback products.

## Chat Widget UX

- Prevents duplicate sends while a request is pending.
- Handles API errors and network errors gracefully.
- Input capped at 1000 characters.

## Support Flow Linking

- Order tracking support CTA now opens contact form with prefilled context.
- Contact form supports `subject` and `message` query params for linked workflows.
