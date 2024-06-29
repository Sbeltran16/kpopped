Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

 #Authourization/Logins
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  #Current User
  get "/me", to: "users#me"

  #Post Routes
  resources :posts, only: [:create, :index, :destroy]

  #Users Routes
  get "/search_users", to: "users#search"
  get "/:username", to: "users#show", as: :user_profile

  #Follow Routes
  resources :follows, only: [:create, :destroy]
  get "/follow-status/:username", to: "follows#status"
  get "/follows/followed_posts", to: "follows#followed_posts"

end
