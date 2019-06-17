class Events::ResourcesController < ApplicationController
  RESOURCE_SCOPE = :all

  before_action :set_event
  before_action :set_resources, only: [:edit]
  before_action :event_admin!

  def edit
  end

  def update
    @event.update(resources_params)
    redirect_to @event
  end

  def destroy
    @event.resource_activations.update_all(active: false)
    redirect_to @event
  end

protected

  def set_event
    @event = Event.find_by(slug: params[:event_slug])
    @event ||= Event.find(params[:event_id])
    @errors = false
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t(:rest_404, type: I18n.t(:event))
    redirect_to events_path && return
  end

  def set_resources
    scope =  self.class.const_get(:RESOURCE_SCOPE)
    @type = scope == :all ? :resources : scope
    @event_resources = @event.send(@type)
    @resources = Resource.send(scope) - @event_resources
  end

  def event_admin!
    redirect_to(@event, notice: t(:admin_only)) unless @event.admin?(Current.user)
  end

  def resources_params
    params.require(:event).permit(resource_ids: [])
  end
end
