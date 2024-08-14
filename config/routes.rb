Rails.application.routes.draw do
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
    devise_for :accounts, path: "", path_names: {
      sign_in: "login", sign_out: "logout", registration: "register"
    },
    controllers: {
      registrations: "accounts",
      sessions: "sessions"
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

    resources :requests, only: %i(new create index update) do
      member do
        patch :update
      end
    end
    resources :books do
      resources :comments, only: %i(create index)
    end
    get "borrow_books", to: "borrow_books#index", as: :borrow_books
  end
end
