Rails.application.routes.draw do
  devise_for :users
  resources :posts
  #get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  post "toggle_like", to: "likes#toggle_like", as: :toggle_like

  resources :comments, only: [:create, :destroy]
  resources :users, only: [:show]

  post "follow", to: "follows#follow", as: :follow
  delete 'unfollow', to: 'follows#unfollow', as: :unfollow
  delete 'cancel_req', to: 'follows#cancel_req', as: :cancel_req

  post 'accept_follow', to: 'follows#accept_follow', as: :accept_follow
  delete 'decline_follow', to: 'follows#decline_follow', as: :decline_follow


end
