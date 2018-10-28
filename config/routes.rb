Rails.application.routes.draw do
  concern :draftable do
    resources :drafts, shallow: true, only: %i[index edit update show destroy]
  end

  devise_for :users, controllers: { registrations: 'user/registrations' }

  root 'pages#show', page: 'home'

  resources :drafts, only: %i[index show update destroy]
  resources :pages

  get '/:page', to: 'pages#show'

  match '*unmatched_route', to: 'application#not_found', via: :all
end
