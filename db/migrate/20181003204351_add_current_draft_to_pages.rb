class AddCurrentDraftToPages < ActiveRecord::Migration[5.2]
  def change
    add_reference :pages, :current_draft, foreign_key: { to_table: :drafts }, null: false
  end
end
