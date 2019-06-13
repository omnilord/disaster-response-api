Rails.application.routes.draw do
  concern :draftable do
    resources :drafts, shallow: true, only: %i[index edit update show destroy]
  end

  devise_for :users, controllers: { registrations: 'user/registrations' }

  root 'pages#page', page: 'home'

  resources :users, only: %i[index show edit update destroy]
  resources :drafts, only: %i[index show update destroy]
  resources :pages, concerns: %i[draftable]
  resources :resources, concerns: %i[draftable]

  resources :events, param: :slug do
    concerns :draftable, module: :events

    # Event Managers
    get '/managers', to: 'events/managers#edit'
    patch '/managers', to: 'events/managers#update'
    delete '/managers', to: 'events/managers#destroy'

    # Event Resources
    constraints(lambda { |request| Resource::TYPE_ROUTES
                                     .include?(request.parameters[:resource_type]) }) do
      get '/:resource_type', to: 'events/resources#edit', as: :resources
      patch '/:resource_type', to: 'events/resources#update'
      delete '/:resource_type', to: 'events/resources#destroy'
    end
  end

  get '/:page', to: 'pages#page'

  match '*unmatched_route', to: 'application#render_not_found', via: :all
end
