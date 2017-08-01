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

  # Collections
  get '/public_collections' => 'word_collections#get_public_collections'
  get '/collections' => 'word_collections#get_collections'
  post '/collections' => 'word_collections#create_collection'
  patch '/collections/:id' => 'word_collections#change_collection_name'
  delete '/collections/:id' => 'word_collections#delete_collection'

  # Words
  get '/collections/:id/words' => 'words#get_words_from_collection'
  post '/collections/:id/words' => 'words#create_word'
  patch '/words/:id' => 'words#edit_word'
  delete '/words/:id' => 'words#delete_word'
end
