Rails.application.routes.draw do
  devise_for :accounts, only: :omniauth_callbacks, controllers: {
    omniauth_callbacks: "accounts/omniauth_callbacks"
  }
  scope "(:locale)", locale: /en|vi/ do
    get "static_pages/home"
    get "requests/new", to: "requests#new", as: "new_request"
    root "static_pages#home"
    resources :book_series, only: %i(show)
    resources :users
    resources :ratings, only: %i(create)
    resources :carts, only: %i(create destroy show)
    resources :authors, only: %i(show index)
    resources :favourites, only: %i(create destroy index)
    devise_for :accounts, skip: :omniauth_callbacks , controllers: {
      registrations: "accounts",
      sessions: "sessions",
      omniauth_callbacks: "accounts/omniauth_callbacks"
    }, path_names: {
      sign_in: "login",
      sign_out: "logout",
      registration: "register"
    }
    namespace :admin do
      root "users#index"
      get "requests/show", to: "requests#show", as: "requests_show"
      get "borrowed_books", to: "borrow_books#index", as: :borrowed_books
      resources :requests, only: %i(index update edit)
      resources :users, only: :index do
        member do
          post "due_reminder"
        end
      end
      resources :accounts do
        member do
          post "update_status"
        end
      end
      resources :authors
      resources :books, only: %i(index new create destroy edit update) do
        collection do
          get "borrowed_books"
        end
      end
      resources :borrow_books do
        collection do
          patch :mark_as_returned
        end
      end
    end

    resources :requests, only: %i(new create index update show edit)
    resources :books do
      resources :comments do
        member do
          get "reply"
        end
      end
    end
    get "borrow_books", to: "borrow_books#index", as: :borrow_books

    namespace :api do
      namespace :v1 do
        resources :users, only: %i(show create update)
        namespace :admin do
          resources :users, only: :index do
            member do
              post "due_reminder"
            end
          end
        end
      end
    end
  end
  Devise.mappings[:account].controllers[:omniauth_callbacks] = "accounts/omniauth_callbacks"
end
