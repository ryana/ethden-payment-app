Rails.application.routes.draw do
  root to: 'welcome#index'

  resources :payments, only: [:create, :show, :update]
end
