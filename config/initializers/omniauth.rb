# frozen_string_literal: true

# OmniAuth Configuration for Social Login
# To enable social login, set the following environment variables:
#
# Google OAuth:
#   GOOGLE_CLIENT_ID=your_google_client_id
#   GOOGLE_CLIENT_SECRET=your_google_client_secret
#
# GitHub OAuth:
#   GITHUB_CLIENT_ID=your_github_client_id
#   GITHUB_CLIENT_SECRET=your_github_client_secret
#
# You can obtain these credentials from:
#   Google: https://console.developers.google.com/
#   GitHub: https://github.com/settings/applications/new

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV["GOOGLE_CLIENT_ID"],
           ENV["GOOGLE_CLIENT_SECRET"],
           { scope: "email,profile" }

  provider :github,
           ENV["GITHUB_CLIENT_ID"],
           ENV["GITHUB_CLIENT_SECRET"],
           { scope: "user:email" }
end

OmniAuth.config.allowed_request_methods = [ :post, :get ]
