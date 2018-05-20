Rails.application.routes.draw do
  resources :customers, only: [:create]

  namespace :simple_middleware do
    resources :customers, only: [:create]
  end
end
