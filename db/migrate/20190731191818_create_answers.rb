class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.references :question,
                   foreign_key: { on_delete: :nullify, on_change: :cascade },
                   null: true
      t.references :resource,
                   foreign_key: { on_delete: :cascade, on_change: :cascade },
                   null: false
      t.references :survey_template_question,
                   foreign_key: { on_delete: :nullify, on_change: :cascade },
                   null: true

      t.text :content
      t.json :question_config # This is the question at time of inquiry

      t.references :created_by, foreign_key: { to_table: :users }, index: true, null: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true, null: true
      t.timestamps

      t.index %i[question_id resource_id created_at], name: :latest_answer_by_resource_question_idx
    end
  end
end
