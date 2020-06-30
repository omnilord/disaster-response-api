class EventsController < ApplicationController
  include PageSetup
  include DraftHandler

  before_action :set_event, only: %i[show edit update destroy]
  before_action :admin!, only: %i[destroy]
  before_action :signed_in!, only: %i[new create edit update]
  before_action :set_draft_count_warning, only: [:edit]

  resource_pages

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
    @event =
      if params[:slug].present?
        Event.find_by(slug: params[:slug])
      else
        Event.find(params[:id])
      end
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t(:rest_404, type: I18n.t(:event))
    redirect_to root_path && return
  end

  def clean_activation_dates
    %i[activated deactivated].each do |field|
      unless params[:event][field].blank?
        a = params[:event][field]
        params[:event][field] = Date.strptime(a, Rails.configuration.date_format).strftime('%Y-%m-%d').to_s
      end
    rescue ArgumentError
      params[:event][field] = ''
    end
  end

  def event_params
    clean_activation_dates

    p = params.require(:event).permit(%i[
      name
      disaster_type
      content
      activated
      deactivated
      administrator_id
      latitude
      longitude
      zoom
    ])
    p["longitude"] = p["longitude"].to_f
    p["latitude"] = p["latitude"].to_f
    p["coords"] = Coordinated.coords(lng: p["longitude"], lat: p["latitude"]);
    p
  end
end
