# Launch Commands (Copy/Paste)

Use these commands in order during release.

## 1) Preflight (Local/CI)

```bash
bundle exec rubocop
bundle exec rails test
bundle exec rails test test/controllers/api/v1/contracts_test.rb
bundle exec brakeman -n -q -f json -o brakeman_report.json
```

## 2) Build and Deploy (Docker Reference)

```bash
docker build -t ecommerce-rails:release .
docker run -d --name ecommerce-rails -p 80:80 \
  -e RAILS_ENV=production \
  -e DATABASE_URL=... \
  -e SECRET_KEY_BASE=... \
  ecommerce-rails:release
```

Run migrations:

```bash
docker exec -it ecommerce-rails bundle exec rails db:migrate
```

## 3) Post-Deploy Smoke

```bash
curl -I http://<your-domain>/
curl -s http://<your-domain>/api/v1/products | head
curl -s http://<your-domain>/api/v1/orders | head
```

Expected:

- `/` returns `200`
- `/api/v1/products` includes `meta.pagination`
- `/api/v1/orders` without token returns `401` with standardized `error` envelope

## 4) Optional Authenticated API Check

Generate token in Rails console:

```ruby
user = User.find_by(email: "your@email.com")
puts user.api_token
```

Then call orders endpoint:

```bash
curl -H "Authorization: Bearer <token>" \
  http://<your-domain>/api/v1/orders
```
