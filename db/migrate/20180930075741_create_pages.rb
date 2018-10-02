class CreatePages < ActiveRecord::Migration[5.2]
  def up
    create_table :pages do |t|
      t.text :i18n, default: :en, index: true
      t.text :page, index: { unique: true }
      t.text :title
      t.text :content
      t.integer :editor_id, index: true

      t.timestamps
    end

    add_foreign_key :pages, :users, column: :editor_id, on_delete: :nullify, on_update: :cascade
  end

  def down
    drop_table :pages
  end
end
