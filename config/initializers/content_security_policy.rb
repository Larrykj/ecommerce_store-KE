# frozen_string_literal: true

# Content Security Policy (CSP) — protects against XSS and data injection attacks.
# This is non-negotiable for an e-commerce app handling payment data.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data, "https://fonts.gstatic.com"
    policy.img_src     :self, :https, :data, :blob
    policy.object_src  :none
    policy.script_src  :self, :https, "https://js.stripe.com", "https://checkout.stripe.com"
    policy.style_src   :self, :https, :unsafe_inline, "https://fonts.googleapis.com"
    policy.frame_src   :self, "https://js.stripe.com", "https://hooks.stripe.com", "https://checkout.stripe.com"
    policy.connect_src :self, :https, "https://api.stripe.com", "https://checkout.stripe.com"
    policy.base_uri    :self
    policy.form_action :self, "https://checkout.stripe.com"
  end

  # Generate random per-request nonces for permitted importmap, inline scripts, and inline styles.
  # Using SecureRandom ensures the nonce is unpredictable (session ID was static per session).
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing in development — enforce in production.
  config.content_security_policy_report_only = !Rails.env.production?
end
