Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    get "static_pages/home"
    root "static_pages#home"
    resources :accounts, only: [:new, :create]
    resources :users, only: [:new, :create]
  end
end
