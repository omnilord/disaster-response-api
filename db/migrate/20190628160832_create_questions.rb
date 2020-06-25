class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.text :content, null: false
      t.references :current_draft, foreign_key: { to_table: :drafts }, null: false
      t.boolean :active, default: true

      t.references :created_by, foreign_key: { to_table: :users }, index: true, null: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true, null: true
      t.timestamps
    end
  end
end
