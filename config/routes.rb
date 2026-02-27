Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # Admin namespace
  namespace :admin do
    root "dashboard#index"
    resources :products, only: [ :index, :show, :edit, :update, :destroy ] do
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
  resources :server_times, only: [ :index ]

  resources :products do
    resources :reviews, only: [ :create, :edit, :update, :destroy ] do
      member do
        post :helpful
      end
    end
    # Back-in-stock notifications
    resources :stock_notifications, only: [ :create ]
  end

  resources :categories

  resource :cart, only: [ :show ] do
    post "apply_promo", to: "promo_codes#apply"
    delete "remove_promo", to: "promo_codes#remove"
    patch "update_shipping", to: "carts#update_shipping"
  end

  resources :cart_items, only: [ :create, :update, :destroy ]

  resources :orders, only: [ :index, :show, :new ] do
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

  # API
  namespace :api do
    namespace :v1 do
      resources :products, only: [ :index, :show ]
      resources :orders, only: [ :index, :show ]
    end
  end
end
