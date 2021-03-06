module Coordinated
  extend ActiveSupport::Concern

  def self.coords(lng:, lat:, srid: 4326)
    "SRID=#{srid};POINT(#{lng} #{lat})"
  end

  def latitude
    coords&.lat
  end
  alias_method :lat, :latitude

  def latitude=(value)
    coords = Coordinated.coords(lng: longitude, lat: value.to_f)
  end
  alias_method :lat=, :latitude=

  def longitude
    coords&.lon
  end
  alias_method :lon, :longitude
  alias_method :lng, :longitude

  def longitude=(value)
    coords = Coordinated.coords(lng: value.to_f, lat: latitude)
  end
  alias_method :lon=, :longitude=
end
