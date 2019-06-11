class AddTrustedFlagToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :trusted, :boolean, default: false
  end
end
