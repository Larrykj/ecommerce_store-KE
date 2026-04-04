# frozen_string_literal: true

# Rate limiting configuration using Rack::Attack
Rails.application.config.middleware.use Rack::Attack

# Throttle checkout attempts — prevent abuse
Rack::Attack.throttle("checkout/limit", limit: 5, period: 1.minute) do |req|
  req.ip if req.path == "/checkout" && req.post?
end

# Throttle order creation
Rack::Attack.throttle("orders/create", limit: 5, period: 1.minute) do |req|
  req.ip if req.path.match?(%r{\A/orders\z}) && req.post?
end

# Throttle API requests per endpoint
Rack::Attack.throttle("api/products", limit: 60, period: 1.minute) do |req|
  req.ip if req.path.start_with?("/api/v1/products")
end

Rack::Attack.throttle("api/orders", limit: 30, period: 1.minute) do |req|
  req.ip if req.path.start_with?("/api/v1/orders")
end

Rack::Attack.throttle("api/ai/chat", limit: 10, period: 1.minute) do |req|
  req.ip if req.path.include?("/ai/chat")
end

Rack::Attack.throttle("api/ai/recommendations", limit: 30, period: 1.minute) do |req|
  req.ip if req.path.include?("/ai/recommendations")
end

# Throttle Stripe webhook — prevent replay attacks
Rack::Attack.throttle("webhooks/stripe", limit: 100, period: 1.minute) do |req|
  req.ip if req.path == "/webhooks/stripe" && req.post?
end

# Throttle contact form submissions
Rack::Attack.throttle("contact/create", limit: 3, period: 1.minute) do |req|
  req.ip if req.path == "/contact" && req.post?
end
