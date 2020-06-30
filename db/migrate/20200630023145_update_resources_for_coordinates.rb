class UpdateResourcesForCoordinates < ActiveRecord::Migration[5.2]
  def up
    remove_column :resources, :latitude
    remove_column :resources, :longitude
    remove_column :resources, :google_place_id
    add_column :resources, :coords, :st_point, geographic: true, srid: 4326, null: false
    add_column :resources, :country, :text
  end

  def down
    remove_column :resources, :country
    remove_column :resources, :coords
    add_column :resources, :latitude, :text
    add_column :resources, :longitude, :text
    add_column :resources, :google_place_id, :text
  end
end
