Rails.application.routes.draw do
  # ── Admin ──────────────────────────────────────────────────────────────────
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # ── User auth (custom controllers for post-auth redirects) ─────────────────
  devise_for :users,
             path: "",
             controllers: {
               sessions:      "users/sessions",
               registrations: "users/registrations",
               passwords:     "users/passwords",
               confirmations: "users/confirmations"
             },
             path_names: {
               sign_in:  "login",
               sign_out: "logout",
               sign_up:  "register"
             }

  # ── Public ─────────────────────────────────────────────────────────────────
  root "home#index"

  get "welcome", to: "welcome#show", as: :welcome

  # Public marketplace browsing (no login required)
  resources :listings, only: [:index, :show] do
    resource :favorite, only: [:create], controller: "favorites"
  end

  # ── Portal ─────────────────────────────────────────────────────────────────
  namespace :portal do
    get "/",      to: "dashboard#show", as: :root  # /portal → role-based redirect

    # Buyer
    namespace :buyer do
      resources :orders, only: [:index, :show, :create] do
        member do
          patch :cancel
          post  :invoice, to: "/portal/invoices#create", as: :generate_invoice
        end
      end
    end

    # Seller
    get "seller",           to: "seller/dashboard#show", as: :seller

    namespace :seller do
      get "/", to: "dashboard#show", as: :root
      resources :listings do
        member do
          patch :publish
          patch :unpublish
          patch :pause
          patch :archive
          patch :mark_sold
          post  :duplicate
        end
      end
      resources :orders, only: [:index, :show] do
        member do
          patch :update_status
          patch :cancel
        end
      end
    end

    # Invoices
    resources :invoices, only: [:index, :show]

    # Favorites (buyer portal)
    resources :favorites, only: [:index]

    # Saved searches
    resources :saved_searches, only: [:index, :create, :destroy] do
      member { patch :toggle_alert }
    end

    # Notifications
    resources :notifications, only: [:index, :show] do
      collection { patch :mark_all_read }
    end

    # Warehouse
    namespace :warehouse do
      get "/", to: "dashboard#show", as: :root
      resources :warehouses, only: [:index, :show, :new, :create, :edit, :update]
      resources :inventory_items, only: [:index, :show] do
        member { patch :adjust }
      end
    end

    # Reports
    namespace :reports do
      get "/",         to: "overview#show",   as: :root
      get "revenue",   to: "revenue#show",    as: :revenue
      get "listings",  to: "listings#show",   as: :listings
      get "inventory", to: "inventory#show",  as: :inventory
    end

    # CRM
    namespace :crm do
      get "/", to: "dashboard#show", as: :root
      resources :contacts do
        resources :contact_notes, only: [:create, :destroy], shallow: true
      end
    end

    # Service Center
    get "service", to: "service/dashboard#show", as: :service
    namespace :service do
      get "/", to: "dashboard#show", as: :root
      resources :service_requests, only: [:index, :show, :new, :create, :edit, :update] do
        member do
          patch :assign
          patch :transition
        end
      end
    end

    # Subscription & billing
    resource  :subscription, only: [:show, :create, :destroy], controller: "subscriptions" do
      get :plans, on: :collection
    end

    # Activity Logs
    resources :activity_logs, only: [:index]

    # API Tokens (portal UI)
    resources :api_tokens, only: [:index, :create, :destroy]

    # AI helpers (JSON, called from listing form)
    namespace :ai do
      post :describe
      post :price
    end

    # Settings
    namespace :settings do
      resource  :profile,     only: [:show, :update], controller: "profiles"
      resource  :account,     only: [:show, :update], controller: "accounts"
      resource  :password,    only: [:show, :update], controller: "passwords"
      resources :memberships, only: [:index, :create, :update, :destroy]
    end
  end

  # ── API ────────────────────────────────────────────────────────────────────
  namespace :api do
    namespace :v1 do
      # Token management (session-authed — not token-authed)
      resources :tokens, only: [:index, :create, :destroy]

      # Auth introspection
      get "me", to: "auth#me"

      # Listings
      resources :listings, only: [:index, :show, :create, :update, :destroy]

      # Orders
      resources :orders, only: [:index, :show] do
        member do
          patch :update_status
          patch :cancel
        end
      end

      # Inventory
      resources :inventory, only: [:index, :show], controller: "inventory" do
        member { post :adjust }
      end

      # AI helpers
      namespace :ai do
        post :describe
        post :price
        post :search
      end
    end
  end

  # ── Health check ───────────────────────────────────────────────────────────
  get "up" => "rails/health#show", as: :rails_health_check
end
