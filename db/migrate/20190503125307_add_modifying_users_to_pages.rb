class AddModifyingUsersToPages < ActiveRecord::Migration[5.2]
  def up
    add_reference :pages, :created_by, foreign_key: { to_table: :users }, index: true, null: true
    add_reference :pages, :updated_by, foreign_key: { to_table: :users }, index: true, null: true
    Page.all.each do |page|
      page.update_column :updated_by_id, page.editor_id
    end
    remove_reference :pages, :editor
  end

  def down
    add_reference :pages, :editor, foreign_key: { to_table: :users }, index: true, null: true
    Page.all.each do |page|
      page.update_column :editor_id, page.updated_by_id
    end
    remove_reference :pages, :created_by
    remove_reference :pages, :updated_by
  end
end
