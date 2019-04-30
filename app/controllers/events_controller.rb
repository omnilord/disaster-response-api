class EventsController < ApplicationController
  include PageSetup
  include DraftHandler

  before_action :set_event, only: %i[show edit update destroy]
  before_action :admin!, only: %i[destroy]
  before_action :set_draft_count_warning, only: [:edit]

  resource_pages create: true, content: I18n.t(:press_edit, type: I18n.t(:page))

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

  def set_event
    @event = Event.find_by(slug: params[:id])
    @event ||= Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t(:rest_404, type: I18n.t(:event))
    redirect_to root_path && return
  end

  def event_params
    %i[activated deactivated].each do |field|
      unless params[:event][field].blank?
        a = params[:event][field]
        params[:event][field] = Date.strptime(a, Rails.configuration.date_format).strftime('%Y-%m-%d').to_s
      end
    rescue ArgumentError
      params[:event][field] = ''
    end

    params.require(:event).permit(:name, :disaster_type, :content, :activated, :deactivated, :administrator_id)
  end
end
