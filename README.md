# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

API

Session
  login: post '/login' => { username: user_name, password: user_password }
  logout: get '/logout'

User
  register: post '/users' => { user: { username: 'newuser', email: 'newuser@email.com',
                                       password: 'password', password_confirmation: 'password' }
  delete: delete '/users'
  change username: patch '/change_username' => { user: { username: new_username }, auth_token: token }
  change email: patch '/change_email' => { user: { email: new_email }, auth_token: token }
  change password: patch '/change_password' => { user: { password: new_password, password_confirmation: new_password }, auth_token: token }

Collections
  get public collections: get '/public_collections' => { auth_token: token }
  get user collections: get '/collections' => { auth_token: token }
  create collection: post '/collections' => { word_collection: { name: collection_name }, auth_token: token }
  change collection name: patch '/collections/:id' => { word_collection: { name: new_name }, auth_token: token }
  delete collection: delete '/collections/:id' => { auth_token: token }

Words
  get words from collection: get '/collections/:id/words' => { auth_token: token }
  create word: post '/collections/:id/words' => { word: { definition: 'def', translation: 'trans' }, auth_token: token }
  edit words: patch '/words/:id' => { word: { definition: 'def', translation: 'trans' }, auth_token: token }
  delete word: delete '/words/:id' => { auth_token: token }
