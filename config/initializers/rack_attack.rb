# frozen_string_literal: true

# Rate limiting configuration using Rack::Attack
# Protects against brute force, abuse, and replay attacks.
Rails.application.config.middleware.use Rack::Attack

# ============ AUTHENTICATION ============

# Throttle login attempts — prevent brute force attacks
Rack::Attack.throttle("auth/login", limit: 10, period: 1.minute) do |req|
  req.ip if req.path.include?("/users/sign_in") && req.post?
end

# Throttle registration — prevent mass account creation
Rack::Attack.throttle("auth/signup", limit: 5, period: 1.minute) do |req|
  req.ip if req.path.include?("/users") && req.post? && !req.path.include?("/sign_in")
end

# Throttle password reset requests
Rack::Attack.throttle("auth/password_reset", limit: 5, period: 5.minutes) do |req|
  req.ip if req.path.include?("/users/password") && req.post?
end

# ============ CHECKOUT & PAYMENTS ============

# Throttle checkout attempts — prevent abuse
Rack::Attack.throttle("checkout/limit", limit: 5, period: 1.minute) do |req|
  req.ip if req.path == "/checkout" && req.post?
end

# Throttle order creation
Rack::Attack.throttle("orders/create", limit: 5, period: 1.minute) do |req|
  req.ip if req.path.match?(%r{\A/orders\z}) && req.post?
end

# Throttle Stripe webhook — prevent replay attacks
Rack::Attack.throttle("webhooks/stripe", limit: 100, period: 1.minute) do |req|
  req.ip if req.path == "/webhooks/stripe" && req.post?
end

# ============ API ENDPOINTS ============

# Global API throttle — 100 requests per minute per IP
Rack::Attack.throttle("api/global", limit: 100, period: 1.minute) do |req|
  req.ip if req.path.start_with?("/api/")
end

# Stricter throttle for API products
Rack::Attack.throttle("api/products", limit: 60, period: 1.minute) do |req|
  req.ip if req.path.start_with?("/api/v1/products")
end

# Stricter throttle for API orders (authenticated)
Rack::Attack.throttle("api/orders", limit: 30, period: 1.minute) do |req|
  req.ip if req.path.start_with?("/api/v1/orders")
end

# AI chat — expensive, limit aggressively
Rack::Attack.throttle("api/ai/chat", limit: 10, period: 1.minute) do |req|
  req.ip if req.path.include?("/ai/chat")
end

# AI recommendations — moderate limit
Rack::Attack.throttle("api/ai/recommendations", limit: 30, period: 1.minute) do |req|
  req.ip if req.path.include?("/ai/recommendations")
end

# Stripe PaymentIntent creation — prevent abuse
Rack::Attack.throttle("api/payments", limit: 10, period: 1.minute) do |req|
  req.ip if req.path.include?("/payments/create_intent") && req.post?
end

# ============ USER-FACING FORMS ============

# Throttle contact form submissions
Rack::Attack.throttle("contact/create", limit: 3, period: 1.minute) do |req|
  req.ip if req.path == "/contact" && req.post?
end

# Throttle newsletter subscriptions
Rack::Attack.throttle("subscribers/create", limit: 3, period: 1.minute) do |req|
  req.ip if req.path == "/subscribers" && req.post?
end

# ============ RESPONSE HEADERS ============

# Add Retry-After header for throttled requests
Rack::Attack.throttled_responder = lambda do |request|
  match_data = request.env["rack.attack.match_data"] || {}
  now = match_data[:epoch_time] || Time.now.to_i
  retry_after = (match_data[:period] || 60) - (now % (match_data[:period] || 60))

  [
    429,
    {
      "Content-Type" => "application/json",
      "Retry-After" => retry_after.to_s
    },
    [ { error: "Rate limit exceeded. Retry after #{retry_after} seconds." }.to_json ]
  ]
end
