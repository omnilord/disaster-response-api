class Event < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include Draftable

  enum disaster_type: {
    earthquake: 'earthquake',
    flood: 'flood',
    hurricane: 'hurricane',
    riot: 'riot',
    storm: 'storm',
    tornado: 'tornado',
    tsunami: 'tsunami',
    warfare: 'warfare',
    wildfire: 'wildfire',
    other: 'other'
  }

  # each geom represents a snapshot map in time.  If there are several,
  # distinct regions associated with an event, use of a MultiPolygon is expected.
  #
  # Events such as a tornado, should be a LineString; storms with multiple tornados
  # could use a MultiLineString type
  #
  # Earthquakes and "riots" could be an "epicenter" or Point, with a radius
  # Multiple epicenters (such as aftershocks) can be represented as MultiPoint
  # has_many :event_geoms

  # events should have a designated management team responsible for overseeing
  # operational data and ensuring that updates are timely and consistent
  has_many :event_managers, dependent: :destroy
  has_many :managers, through: :event_managers, source: :user
  belongs_to :created_by, class_name: 'User', default: -> { Current.user }
  belongs_to :updated_by, class_name: 'User', default: -> { Current.user }
  belongs_to :administrator, class_name: 'User', default: -> { Current.user }

  accepts_nested_attributes_for :managers, allow_destroy: true

  # publications are micro-news bits that get pushed out to various outlets
  # Could be as simple as a URL to a news outlet that generates an OEmbed preview
  # TODO: has_many :publications

  validates :slug, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A\w+-\d{4}\z/, message: I18n.t(:invalid_slug_format) }

  after_initialize :init_defaults

  before_validation(on: :create) do |m|
    year = Date.current.year.to_s
    m.name = "#{m.name} #{year}" unless m.name.end_with?(year)
    m.slug = name.downcase.gsub(/[^\w]+/i, '-')
  end

  before_save :sanitize!

  scope :active, -> { where(deactivated: nil) }
  scope :inactive, -> { where.not(deactivated: nil) }

  def to_param
    slug
  end

  def link_to_text
    name
  end

  def draft_type
    name
  end

  def admin?(user)
    return false if user.nil?
    user.admin? || administrator == user
  end

  def manager?(user)
    return false if user.nil?
    admin?(user) || managers.exists?(user)
  end

  def humanize_disaster_type
    humanize_enum(:disaster_type)
  end

  def activated
    super&.strftime(Rails.configuration.date_format)
  end

  def deactivated
    super&.strftime(Rails.configuration.date_format)
  end

private

  def sanitize!
    self.name = sanitize(self.name)
    self.content = sanitize(self.content, tags: ALLOWED_HTML_TAGS, attributes: ALLOWED_HTML_ATTRIBUTES)
  end

  def init_defaults
    self.activated ||= Date.today.strftime(Rails.configuration.date_format).to_s
    self.disaster_type ||= Rails.configuration.default_disaster_type
  end
end
