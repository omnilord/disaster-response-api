class Events::ManagersController < ApplicationController
  before_action :set_event
  before_action :event_admin!
  before_action :set_users, only: [:edit]

  def edit
  end

  def update
    @event.update(manager_params)
    redirect_to @event
  end

  def destroy
    @event.update(manager_ids: [])
    redirect_to @event
  end

private

  def set_event
    @event = Event.find_by(slug: params[:event_slug])
    @event ||= Event.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t(:rest_404, type: I18n.t(:event))
    redirect_to events_path && return
  end

  def set_users
    @users = User.live.not_admin
  end

  def event_admin!
    redirect_to(@event, notice: t(:admin_only)) unless @event.admin?(Current.user)
  end

  def manager_params
    params.require(:event).permit(:administrator_id, manager_ids: [])
  end
end
