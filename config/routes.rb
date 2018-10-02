Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'user/registrations' }

  root 'pages#show', page: 'home'

  resources :pages

  get '/:page', to: 'pages#show'

  match '*unmatched_route', to: 'application#not_found', via: :all
end
