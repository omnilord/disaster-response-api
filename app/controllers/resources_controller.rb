class ResourcesController < ApplicationController
  include PageSetup
  include DraftHandler

  before_action :set_resource, only: %i[show edit update destroy]
  before_action :admin!, only: %i[destroy]
  before_action :signed_in!, only: %i[new create edit update]
  before_action :set_draft_count_warning, only: [:edit]

  resource_pages

  def index
    scoping =
      if Resource::TYPE_ROUTES.include?(params[:resource_type])
        params[:resource_type].strip.singularize.downcase.to_sym
      else
        :all
      end
    @resources = Resource.send(scoping)
  end

  def new
    @resource =
      if Resource::TYPE_KEYS.include?(params[:resource_type]&.downcase&.singularize&.to_sym)
        Resource.new(resource_type: params[:resource_type])
      else
        Resource.new
      end
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
    @resource.destroy
    redirect_to resources_path, notice: I18n.t(:destroy_success, type: I18n.t(:resource))
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_resource
    @resource = Resource.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:resource).permit(%i[
      name
      resource_type
      latitude
      longitude
      google_place_id
      address
      city
      county
      state
      postal_code
      primary_phone
      secondary_phone
      private_contact
      private_email
      private_phone
      private_notes
      latest_data_source
      notes
      active
    ])
  end
end
