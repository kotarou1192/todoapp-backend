# frozen_string_literal: true

Rails.application.routes.draw do
  get 'hello_world/index', to: 'hello_world#index'
  post '/users/create', to: 'users#create'
  post '/users/delete', to: 'users#destroy'
  post '/users/edit', to: 'users#update'
  post '/users/login', to: 'users#login'
  post '/users/logout', to: 'users#logout'
  post '/todo_lists/get', to: 'todo_lists#index'
  post '/todo_lists/create', to: 'todo_lists#create'
  delete '/todo_lists/delete', to: 'todo_lists#destroy'
  patch '/todo_lists/update', to: 'todo_lists#update'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # resources :todo_lists
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: %i[new create edit update]

  # post 'password_resets', to: 'password_resets#create'
  # get 'password_resets/new', to: 'password_resets#new'
end
