class SurveyTemplateQuestion < ApplicationRecord
  belongs_to :survey_template, inverse_of: :survey_template_questions
  belongs_to :question, inverse_of: :survey_template_questions


  scope :ordered_questions, -> { includes(:question).order(:position).map(&:question) }
end
