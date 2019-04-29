Rails.application.routes.draw do
  concern :draftable do
    resources :drafts, shallow: true, only: %i[index edit update show destroy]
  end

  devise_for :users, controllers: { registrations: 'user/registrations' }

  root 'pages#page', page: 'home'

  resources :drafts, only: %i[index show update destroy]
  resources :pages, concerns: %i[draftable]
  resources :events, concerns: %i[draftable] do
    get '/managers', to: 'events/managers#edit'
    patch '/managers', to: 'events/managers#update'
    delete '/managers', to: 'events/managers#destroy'
  end

  get '/:page', to: 'pages#page'

  match '*unmatched_route', to: 'application#not_found', via: :all
end
