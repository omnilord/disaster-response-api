class CreateDrafts < ActiveRecord::Migration[5.2]
  def change
    create_table :drafts do |t|
      t.references :draftable, polymorphic: true
      t.jsonb :data
      t.references :user, foreign_key: true
      t.references :approved_by, foreign_key: { to_table: :users }
      t.timestamp :approved_at
      t.references :denied_by, foreign_key: { to_table: :users }
      t.timestamp :denied_at

      t.timestamps
    end
  end
end
