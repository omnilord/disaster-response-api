class CreateResources < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.text :name, null: false, index: true
      t.text :resource_type, null: false, index: { using: :hash }
      t.text :latitude
      t.text :longitude
      t.text :google_place_id
      t.text :address
      t.text :city
      t.text :county
      t.text :state
      t.text :postal_code
      t.text :primary_phone
      t.text :secondary_phone
      t.text :private_contact
      t.text :private_email
      t.text :private_phone
      t.text :private_notes
      t.text :notes
      t.text :latest_data_source
      t.references :current_draft, foreign_key: { to_table: :drafts }, null: false
      t.boolean :active, default: true

      t.references :created_by, foreign_key: { to_table: :users }, index: true, null: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true, null: true
      t.timestamps
    end
  end
end
