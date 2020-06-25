class Answer < ApplicationRecord
  belongs_to :created_by, class_name: 'User', default: -> { Current.user }
  belongs_to :updated_by, class_name: 'User', default: -> { Current.user }
  belongs_to :question, optional: true
  belongs_to :survey_template_question, optional: true
  belongs_to :resource

  before_create do |answer|
    answer.question = answer.survey_template_question.question
    answer.question_config = {
      current_draft_id: answer.question.current_draft_id,
      content: answer.question.content
    }
  end

  def self.most_recent
    select(:question_id, 'MAX(created_at) AS created_at').group(:question_id).map do |qts|
      Answer.find_by(question_id: qts[:question_id], created_at: qts[:created_at])
    end.compact
  end

  def edited?
    [created_at, created_by] != [updated_at, updated_by]
  end
end
