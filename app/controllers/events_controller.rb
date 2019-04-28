class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]
  before_action :admin!, only: %i[destroy]

  def index
    @active_events = Event.active
    @inactive_events = Event.inactive
  end

  def new
    @event = Event.new
  end

  def create
    save_or_draft :create
  end

  def edit
  end

  def show
  end

  def update
    save_or_draft :update
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: I18n.t(:destroy_success, type: I18n.t(:event))
  end

private

  def save_or_draft(method)
    @draft, success, pending, error_render =
      if method == :create
        [
          Draft.new(draftable_type: Event, data: event_params),
          :new_success, :new_draft_pending, :new
        ]
      else
        [
          Draft.new(draftable: @event, data: event_params),
          :update_success, :update_draft_pending, :edit
        ]
      end


    if @draft.save
      if Current.user&.admin? && @draft.approve
        @event = @draft.draftable
        redirect_to events_path, notice: I18n.t(success, type: "`#{@event.name}` #{I18n.t(:event)}")
      else
        redirect_to @draft, notice: I18n.t(pending, draft: I18n.t(:event))
      end
    else
      flash[:error] = @draft.errors.full_messages || I18n.t(:generic_error)
      render error_render
    end
  end

  def set_event
    @event = Event.find_by(slug: params[:id])
    @event ||= Event.find_(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t(:rest_404, type: I18n.t(:event))
    redirect_to root_path && return
  end

  def event_params
    params.require(:event).permit(:name, :disaster_type, :content, :activated, :deactivated, :administrator_id)
  end
end
