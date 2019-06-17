Rails.application.routes.draw do
  dynamic_resource_routes = lambda do |route, target, create: false|
    post route, to: "#{target}#create" if create
    get route, to: "#{target}#edit"
    patch route, to: "#{target}#update"
    put route, to: "#{target}#update"
    delete route, to: "#{target}#destroy"
  end

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
    dynamic_resource_routes.call('/managers', 'events/managers')

    # Event Resources
    dynamic_resource_routes.call('/resources', 'events/resources', create: true)
    dynamic_resource_routes.call('/shelters', 'events/shelters')
    dynamic_resource_routes.call('/pods', 'events/pods')
    dynamic_resource_routes.call('/medsites', 'events/med_sites')

    # TODO: Eventually come back to this when dynamic enums for types are a thing
    # constraints(lambda { |request| request.parameters[:resource_type] == 'resources' \
    #                                 || Resource::TYPE_ROUTES
    #                                 .include?(request.parameters[:resource_type]) }) do
    #   get '/:resource_type', to: 'events/resources#edit' , as: :resources
    #   patch '/:resource_type', to: 'events/resources#update'
    #   delete '/:resource_type', to: 'events/resources#destroy'
    # end
  end

  get '/:page', to: 'pages#page'

  match '*unmatched_route', to: 'application#render_not_found', via: :all
end
