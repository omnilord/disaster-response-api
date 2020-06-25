class SurveyTemplate < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include Draftable

  enum resource_type: Resource.resource_types.dup

  belongs_to :created_by, class_name: 'User', default: -> { Current.user }
  belongs_to :updated_by, class_name: 'User', default: -> { Current.user }

  # QUESTIONS
  has_many :survey_template_questions, dependent: :destroy, inverse_of: :survey_template
  has_many :questions, through: :survey_template_questions

  accepts_nested_attributes_for :survey_template_questions, allow_destroy: true

  scope :with_questions, -> { includes(:survey_template_questions, :questions) }
  scope :by_resource_type, ->(type) { find_by(resource_type: type) }

  def self.ordered_questions(type)
    find_by(resource_type: type)
      &.survey_template_questions
      &.ordered_questions
  end

  def link_to_text
    Resource.title_for(resource_type)
  end

  def draft_type
    resource_type
  end

  def admin?(user)
    return false if user.nil?
    user.admin?
  end

  def trusted?(user)
    return false if user.nil?
    user.admin? || user.trusted?
  end

  def draft_approver?(user)
    trusted?(user)
  end
end
