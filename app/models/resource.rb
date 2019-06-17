class Resource < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include Draftable

  TYPE_KEYS = %i[shelter pod medsite].freeze
  TYPE_ROUTES = TYPE_KEYS.map { |t| t.to_s.pluralize }.freeze
  TYPE_TEXTS = ['shelter', 'distribution point', 'medical site'].freeze

  enum resource_type: TYPE_KEYS.zip(TYPE_TEXTS).to_h

  belongs_to :created_by, class_name: 'User', default: -> { Current.user }
  belongs_to :updated_by, class_name: 'User', default: -> { Current.user }

  # EVENTS
  has_many :resource_activations, dependent: :destroy
  has_many :events, through: :resource_activations

  validates :name, presence: true
  validates :resource_type, presence: true

  before_save :sanitize!
  before_save -> { self.updated_by = Current.user }

  scope :active, -> { where(active: true) }
  scope :shelters, -> { where(resource_type: :shelter) }
  scope :pods, -> { where(resource_type: :pod) }
  scope :medsites, -> { where(resource_type: :medsite) }

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

  def draft_approver?(user)
    trusted?(user)
  end

  def admin?(user)
    return false if user.nil?
    user.admin?
  end

  def trusted?(user)
    return false if user.nil?
    user.admin? || user.trusted?
  end

  def humanize_resource_type
    humanize_enum(:resource_type)
  end

  def resource_activation(event)
    ResourceActivation.where(event: event, resource: self).first
  end

private

  def sanitize!
    internal_cols = %w[id resource_type latitude longitude current_draft_id active created_by_id updated_by_id created_at updated_at]
    Array(Resource.column_names - internal_cols).each do |col|
      self.send("#{col}=", sanitize(self.send(col)))
    end
    self.latitude = self.latitude.to_f.to_s
    self.longitude = self.longitude.to_f.to_s
  end
end
