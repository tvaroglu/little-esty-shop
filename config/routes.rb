Rails.application.routes.draw do

  root 'welcome#index'
  get '/refresh', to: 'welcome#refresh'

  resources :merchants, only: [:show, :index], module: :merchant do
      resources :items
      resources :invoices
      resources :discounts
      resources :dashboard, only: [:index]
  end

  namespace :admin do
    resources only: [:index]
    resources :merchants
    resources :invoices
  end
end
