# frozen_string_literal: true

# CORS configuration for mobile app API access.
# Allows Android app and web frontend to access /api/* endpoints.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allowed_origins = if Rails.env.production?
    [ "https://ecommerce-rails-app.onrender.com" ]
  else
    [
      "http://localhost:3000",
      "http://10.0.2.2:3000"
    ]
  end

  # API endpoints — accessible by mobile apps and web frontends
  allow do
    origins(*allowed_origins)

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: false,
      max_age: 3600
  end
end
