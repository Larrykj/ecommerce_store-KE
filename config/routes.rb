Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Admin namespace
  namespace :admin do
    root "dashboard#index"
    resources :categories, except: [ :show ] do
      member do
        post :restore
      end
    end
    resources :products do
      member do
        patch :restore
      end
    end
    resources :orders, only: [ :index, :show, :update ] do
      resources :refunds, only: [ :create ], controller: "refunds"
    end
    resources :users, only: [ :index, :show ] do
      member do
        patch :toggle_admin
      end
    end
    resources :promo_codes, except: [ :show ]
    resources :shipping_methods, except: [ :show ] do
      member do
        patch :toggle_active
      end
    end
    resources :contact_messages, only: [ :index, :show, :destroy ] do
      member do
        patch :mark_read
      end
    end
    resources :return_requests, only: [ :index, :show, :update ]
    resources :gift_cards, only: [ :index, :new, :create, :destroy ]
    resources :subscribers, only: [ :index, :destroy ]
    resources :loyalty_programs, only: [ :index, :create, :update ]
    resources :loyalty_tiers, only: [ :create, :destroy ]
    resources :loyalty_rewards, only: [ :create, :destroy ]
    resources :blog_posts do
      member do
        patch :publish
      end
    end
    resources :flash_sales do
      member do
        post :add_product
        delete :remove_product
      end
    end
    resources :product_bundles do
      member do
        post :add_product
        delete :remove_product
      end
    end
  end

  root "products#index"

  # User Profile & Addresses
  resource :profile, only: [ :show ]
  resources :addresses, except: [ :show ] do
    member do
      patch :set_default
    end
  end

  resources :wishlist_items, only: [ :index, :create, :destroy ]

  resources :products, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    resources :reviews, only: [ :create, :edit, :update, :destroy ] do
      member do
        post :helpful
      end
    end
    # Back-in-stock notifications
    resources :stock_notifications, only: [ :create ]
  end

  resources :categories, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  resource :cart, only: [ :show ] do
    post "apply_promo", to: "promo_codes#apply"
    delete "remove_promo", to: "promo_codes#remove"
    post "apply_gift_card", to: "gift_cards#apply"
    delete "remove_gift_card", to: "gift_cards#remove"
    patch "update_shipping", to: "carts#update_shipping"
  end

  resources :cart_items, only: [ :create, :update, :destroy ]

  resources :orders, only: [ :index, :show, :new, :create ] do
    member do
      patch :cancel
      patch :update_status
    end
    # Order invoices
    resource :invoice, only: [ :show ]
    # Return requests
    resources :return_requests, only: [ :new, :create ]
  end

  # My return requests
  resources :return_requests, only: [ :index ]

  # Gift Cards
  resources :gift_cards, only: [ :index, :new, :create ]
  post "/gift-cards/check-balance", to: "gift_cards#check_balance", as: :check_gift_card_balance

  # Newsletter
  resources :subscribers, only: [ :create ]
  get "/unsubscribe/:token", to: "subscribers#unsubscribe", as: :unsubscribe

  # Product Comparison
  get "/compare", to: "comparisons#show", as: :comparison
  post "/compare/add", to: "comparisons#add", as: :add_comparison
  delete "/compare/remove", to: "comparisons#remove", as: :remove_comparison
  delete "/compare/clear", to: "comparisons#clear", as: :clear_comparison

  # Checkout & Payments
  post   "/checkout",         to: "checkouts#create",  as: :checkout
  get    "/checkout/success",  to: "checkouts#success", as: :checkout_success
  get    "/checkout/cancel",   to: "checkouts#cancel",  as: :checkout_cancel

  # Stripe Webhooks
  post "/webhooks/stripe", to: "webhooks#stripe"

  get "/server_time", to: "server_time#show"

  # Contact Us
  resources :contact_messages, only: [ :new, :create ], path: "contact"
  get "/contact/thank-you", to: "contact_messages#thank_you", as: :contact_thank_you

  # Static Pages
  get "/about",          to: "pages#about",          as: :about
  get "/faq",            to: "pages#faq",             as: :faq
  get "/privacy-policy", to: "pages#privacy_policy",  as: :privacy_policy
  get "/terms",          to: "pages#terms",            as: :terms
  get "/return-policy",  to: "pages#return_policy",    as: :return_policy
  get "/shipping-info",  to: "pages#shipping_info",    as: :shipping_info

  # Blog
  resources :blog_posts, only: [ :index, :show ] do
    resources :blog_comments, only: [ :create, :destroy ]
  end
  resources :blog_categories, only: [ :index, :show ]

  # Loyalty
  resource :loyalty, only: [ :show ], controller: "loyalty" do
    get :rewards
    post :redeem
  end

  # Sitemap
  get "/sitemap.xml", to: "sitemaps#show"

  # Product Bundles
  resources :product_bundles, only: [ :index, :show ]

  # Flash Sales
  get "/flash-sales", to: "flash_sales#index", as: :flash_sales
  get "/flash-sales/:id", to: "flash_sales#show", as: :flash_sale

  # API
  namespace :api do
    namespace :v1 do
      # Browsing (public — no auth required)
      resources :products, only: [ :index, :show ]
      resources :categories, only: [ :index, :show ]

      # Orders (authenticated)
      resources :orders, only: [ :index, :show ]

      # Native Stripe Integration
      post "/payments/create_intent", to: "payments#create_intent"

      # AI Features
      post "/ai/chat", to: "ai#chat"
      post "/ai/recommendations", to: "ai#recommendations"
    end
  end
end
