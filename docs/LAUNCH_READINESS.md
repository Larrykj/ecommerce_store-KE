# Launch Readiness Checklist

## 1) Security and Credentials

- Keep `.env` out of version control (already ignored).
- Rotate exposed test/temporary keys before sharing the project.
- For production, set secrets in your host environment (Render, Docker, etc), not in files.
- Verify `config/initializers/filter_parameter_logging.rb` includes sensitive keys.

## 2) API Authentication

- API v1 now supports signed bearer tokens with expiry and purpose checks.
- Legacy base64 user-id token remains temporarily supported for backward compatibility.
- Generate a signed token in Rails console:

```ruby
user = User.find_by(email: "your@email.com")
user.api_token
```

- Send as header:

```text
Authorization: Bearer <token>
```

## 3) Throttling and Abuse Protection

- `Rack::Attack` includes rate limits for:
  - login, signup, password reset
  - `/api/v1/ai/chat`
  - `/api/v1/ai/recommendations`
  - generic `/api/v1/*` traffic

## 4) Functional Smoke Tests

- Login page: `GET /users/sign_in` returns 200.
- Profile page unauthenticated: `GET /profile` redirects to `/users/sign_in`.
- Contact page with prefills: `GET /contact/new?subject=Order%20Issue&message=Hello` returns 200.
- AI chat API:
  - blank message returns 422
  - normal message returns JSON response

## 5) Known Non-Blocking Note

- You may still see a boot-time deprecation warning from a dependency (`ActiveSupport::Configurable`).
- This is dependency-level and does not block app runtime; track and remove during dependency upgrade cycle.
