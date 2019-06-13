class CreateResourceActivations < ActiveRecord::Migration[5.2]
  def change
    create_table :resource_activations do |t|
      t.references :event, null: false, index: true
      t.references :resource, null: false, index: true
      t.boolean :active, default: true
      t.json :data
      t.index [:event_id, :resource_id], unique: true, name: 'unique_activation'
    end
  end
end
