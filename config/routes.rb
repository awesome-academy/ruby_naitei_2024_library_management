Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    get 'static_pages/home'
    root 'static_pages#home'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
