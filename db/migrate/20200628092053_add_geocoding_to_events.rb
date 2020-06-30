class AddGeocodingToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :coords, :st_point, geographic: true, srid: 4326, null: false
    add_column :events, :zoom, :decimal, precision: 3, scale: 1, null: false, default: 9.0
  end
end
