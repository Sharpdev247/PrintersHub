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

    # Service
    get "service", to: "service/dashboard#show", as: :service

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
    end
  end

  # ── Health check ───────────────────────────────────────────────────────────
  get "up" => "rails/health#show", as: :rails_health_check
end
