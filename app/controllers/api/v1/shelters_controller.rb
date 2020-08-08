class Api::V1::SheltersController < ApplicationController
  METERS_IN_MILE = 1609.34

  before_action do
    request.format = :json
  end

  def geo
    @shelters =
      if params[:lat].present? && params[:lon].present?
        radius = params.fetch(:radius, 100).to_f * METERS_IN_MILE # 100 miles out
        Shelter.within_radius(params[:lat], params[:lon], radius).all
      else
        Shelter.all
      end
  end
end
