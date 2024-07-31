Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    get "static_pages/home"
    root "static_pages#home"
    resources :books, only: %i(index show)
    resources :accounts, only: [:new, :create] do
      member do
        post "update_status"
      end
    end
    resources :users, only: [:new, :create, :index] do
      member do
        post "due_reminder"
      end
    end
  end
end
