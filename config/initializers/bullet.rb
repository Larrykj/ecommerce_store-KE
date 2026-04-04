# frozen_string_literal: true

# Bullet N+1 query detection configuration (development only)
Rails.application.configure do
  config.after_initialize do
    if Rails.env.development? && defined?(Bullet)
      Bullet.enable        = true
      Bullet.bullet_logger = true
      Bullet.console       = true
      Bullet.rails_logger  = true

      # Don't alert for these common patterns in e-commerce
      Bullet.add_safelist type: :n_plus_one_query, class_name: "Product", association: :variants
      Bullet.add_safelist type: :n_plus_one_query, class_name: "Product", association: :category
      Bullet.add_safelist type: :n_plus_one_query, class_name: "Product", association: :reviews
      Bullet.add_safelist type: :n_plus_one_query, class_name: "OrderItem", association: :variant
    end
  end
end
