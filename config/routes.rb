Rails.application.routes.draw do
  devise_for :users

  root "products#index"



  resources :wishlist_items, only: [ :index, :create, :destroy ]
  resources :server_times, only: [:index]



  resources :products do
    resources :reviews, only: [ :create, :edit, :update, :destroy ] do
      member do
        post :helpful
      end
    end
  end



  resources :categories



  resource :cart, only: [ :show ]

  resources :cart_items, only: [ :create, :update, :destroy ]



  resources :orders, only: [ :index, :show, :new, :create ]

  get "/server_time", to: "server_time#show"
end

# EOF
