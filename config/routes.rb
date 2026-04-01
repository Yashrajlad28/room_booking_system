Rails.application.routes.draw do
  devise_for :users

  root "welcome#index"

  resources :bookings do
    member do
      patch :cancel
    end
  end

end
