module Geocodable
  extend ActiveSupport::Concern
  extend Coordinated

  #
  # Geocoable Concern
  #
  # Adds geocoding to the model so that it can be managed appropriately.
  #

  ADDRESS_FIELDS = %w[addres1 address2 address city state zip postal county country]

  included do
    before_save :geocode, if: ->(s) { !s.geocoded? || (ADDRESS_FIELDS & s.changes.keys).length > 0 }

    geocoded_by :address do |obj, results|
      if geo = results.first
        obj.coords = Coordinated.coords(lng: geo.longitude.to_f, lat: geo.latitude.to_f)
      end
    end
  end

  def geocode!
    unless geocoded?
      puts "Geocoding: #{name}"
      geocode
      save if changed?
    end
  end
end
