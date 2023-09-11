Rails.application.routes.draw do
  namespace :admin do
    resources :users
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :games, only: [ :index, :show, :new, :create ] do
    resources :game_users, only: [ :create ]
    member do
      patch :play_round
    end
  end

  get 'games/:id/game_over', to: 'games#game_over'

  # Defines the root path route ("/")
  root to: "games#index"
end
