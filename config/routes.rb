Rails.application.routes.draw do
  resources :customers, only: [:create]
end
