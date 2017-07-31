Rails.application.routes.draw do
  root to: 'sessions#new'

  # Session
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  # User
  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  delete '/users' => 'users#destroy'
  patch '/change_username' => 'users#change_username'
  patch '/change_email' => 'users#change_email'
  patch '/change_password' => 'users#change_password'
end
