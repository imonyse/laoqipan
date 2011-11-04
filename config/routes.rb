Html5Weiqi::Application.routes.draw do
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/signin' => 'sessions#new', :as => :signin
  match '/signup' => 'users#new', :as => :signup
  match '/duel' => 'games#duel', :as => :duel
  match '/watch' => 'games#index', :as => :index
  match '/games/laoqipan_:id.sgf' => 'games#sgf', :format => "sgf", :as => "game_sgf"
  match '/records' => 'games#records', :as => :records
  match '/upload_sgf' => 'games#upload_sgf', :as => :upload_sgf
  
  match '/reset_password' => 'users#reset_password', :as => :reset_password
  match '/recover_password' => 'users#recover_password', :as => :recover_password
  match '/recovery_session' => 'sessions#recovery', :as => :recovery_session
  
  match '/confirm_email' => 'sessions#confirm_email', :as => :confirm_email
  match '/validate_email' => 'users#validate_email', :as => :validate_email

  # match '/auth', :to => 'authentications#index'
  # match '/auth/:provider/callback', :to => 'authentications#create'
  
  match '/handle_notify', :to => 'sessions#handle_notify', :as => :handle_notify
  match '/notify', :to => 'notifications#notify'
  match '/current_games', :to => 'games#current_games'
  match '/challenge', :to => 'games#gnugo_challenge', :as => :challenge
  
  resources :broadcasts

  resources :sessions
  resources :notices
  resources :relationships, :only => [:create, :destroy]
  
  resources :users do
    resources :invitations
    resources :authentications
    member do
      get :following, :followers
    end
  end
  
  resources :games do
    resources :moves
    resources :comments
  end

  root :to => "pages#index"
  
  if ['development', 'test'].include? Rails.env
    mount Jasminerice::Engine => '/jasmine'
  end
end
