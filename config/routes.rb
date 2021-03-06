Rails.application.routes.draw do

  get 'categories/index'
  root to: 'top#index'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations'
  }

  devise_scope :user do
    get  'addresses', to: 'users/registrations#new_address'
    post 'addresses', to: 'users/registrations#create_address'
  end

  resources :products do
    collection do
      get 'get_category_children',      defaults: { format: 'json' }
      get 'get_category_grandchildren', defaults: { format: 'json' }
      get 'fuzzy_search', to: 'products#fuzzy_search'
    end
    
    member do
      get 'purchase', to: 'products#purchase'
      post 'pay',     to: 'products#pay'
    end
    
    resources :likes, only: [:create, :destroy]

  end

  resources :comments, only: [:create, :update, :destroy] do
    member do
      get 'restore'
    end
  end

  resources :brands, only: [:new, :create]

  resources :accounts, only: [:index, :new, :create, :edit, :update, :show] do
    collection do
      get 'mypage', to: 'accounts#mypage'
      get 'logout', to: 'accounts#logout'
      get :likes
    end
  end

  resources :creditcards, only: [:index ,:new, :create, :show] do
    collection do
      delete 'delete', to: 'creditcards#delete'
      post   "date",   to: 'creditcards#show'
    end
  end

  resources :users, only: :index


  resources :addresses, only: [:edit, :update]


  resources :categories, only: [:index, :show]

end
