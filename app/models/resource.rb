class Resource < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include Draftable
  include Coordinated

  TYPE_KEYS = %i[shelter pod med_site].freeze
  TYPE_ROUTES = TYPE_KEYS.map { |t| t.to_s.pluralize }.freeze
  TYPE_TEXTS = ['shelter', 'distribution point', 'medical site'].freeze

  enum resource_type: TYPE_KEYS.zip(TYPE_TEXTS).to_h

  belongs_to :created_by, class_name: 'User', default: -> { Current.user }
  belongs_to :updated_by, class_name: 'User', default: -> { Current.user }

  # EVENTS
  has_many :resource_activations, dependent: :destroy
  has_many :events, through: :resource_activations

  # SURVEYS
  has_many :answers, dependent: :destroy

  accepts_nested_attributes_for :answers, allow_destroy: true, reject_if: ->(attrs) { attrs[:content].blank? }

  validates :name, presence: true
  validates :resource_type, presence: true

  before_save :sanitize!
  before_save -> { self.updated_by = Current.user }

  scope :active, -> { where(active: true) }
  scope :shelters, -> { where(resource_type: :shelter) }
  scope :pods, -> { where(resource_type: :pod) }
  scope :med_sites, -> { where(resource_type: :med_site) }

  def self.title_for(type_route)
    i = TYPE_ROUTES.find_index(type_route.to_s.downcase)
    i.nil? ? 'Resources' : TYPE_TEXTS[i].pluralize.titleize
  end

  def link_to_text
    name
  end

  def draft_type
    name
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

  def humanize_resource_type
    humanize_enum(:resource_type)
  end

  def resource_activation(event)
    ResourceActivation.where(event: event, resource: self).first
  end

  def survey_questions
    @question_list ||= SurveyTemplate.ordered_questions(self.resource_type)
  end

  def questions_and_answers
    @answer_list ||= answers.most_recent
    @q_and_a ||= begin
      (survey_questions || []).map do |q|
        # Find an answer to these questions in order and move it to this list
        i = @answer_list.find_index { |answer| q == answer.question }
        a = @answer_list.delete_at(i) unless i.nil?

        { question: q, answer: a }
      end + (@answer_list || []).map do |a|
        # append any remaining answers as ad-hoc (maybe the question was removed)
        { question: Question.new(a.question_config), answer: a }
      end
    end
  end

private

  def sanitize!
    internal_cols = %w[id resource_type latitude longitude coords current_draft_id active created_by_id updated_by_id created_at updated_at]
    Array(Resource.column_names - internal_cols).each do |col|
      self.send("#{col}=", sanitize(self.send(col)))
    end
    self.latitude = self.latitude.to_f
    self.longitude = self.longitude.to_f
  end
end
