class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.text :slug, null: false, unique: true
      t.text :name
      t.text :disaster_type
      t.text :content
      t.datetime :activated
      t.datetime :deactivated

      t.references :administrator, index: true, foreign_key: { to_table: :users }
      t.references :created_by, index: true, foreign_key: { to_table: :users }
      t.references :updated_by, index: true, foreign_key: { to_table: :users }
      t.references :current_draft, index: true, foreign_key: { to_table: :drafts }, null: false

      t.timestamps
    end

    create_table :event_managers do |t|
      t.references :event, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
