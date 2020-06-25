class Question < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include Draftable

  belongs_to :created_by, class_name: 'User', default: -> { Current.user }
  belongs_to :updated_by, class_name: 'User', default: -> { Current.user }

  # SURVEYS
  has_many :survey_template_questions, dependent: :destroy, inverse_of: :question
  has_many :survey_templates, through: :survey_template_questions
  has_many :answers, dependent: :nullify

  validates :content, presence: true

  before_save :sanitize!
  before_save -> { self.updated_by = Current.user }

  scope :active, -> { where(active: true) }

  def self.title_for(type_route)
    Resource.title_for(type_route)
  end

  def link_to_text
    content
  end

  def draft_type
    content.truncate(30)
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

private

  def sanitize!
    self.content = sanitize(self.content.strip)
  end
end
