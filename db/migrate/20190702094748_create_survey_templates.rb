class CreateSurveyTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_templates do |t|
      t.text :resource_type, null: false, default: 'shelter', index: { unique: true }
      t.references :current_draft, foreign_key: { to_table: :drafts }, null: false
      t.references :created_by, foreign_key: { to_table: :users }, index: true, null: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true, null: true
      t.text :notes

      t.timestamps
    end

    create_table :survey_template_questions do |t|
      t.references :survey_template, foreign_key: true, index: true, null: false
      t.references :question, foreign_key: true, index: true, null: false
      t.integer :position, null: false, default: 0
      t.boolean :active, default: true
      t.boolean :required, default: false
      t.boolean :private, default: false

      t.index %i[survey_template_id question_id], name: :survey_template_question_ids_unique_idx, unique: true
    end
  end
end
