Rails.application.routes.draw do
  root "quotes#index"

  resources :quotes do
    member do
      patch :validate
    end
    resources :items, only: [:edit, :create, :update, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
