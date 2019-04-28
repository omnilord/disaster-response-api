class User < ApplicationRecord
  has_many :event_managers
  has_many :managed_events, class_name: 'Event', through: :event_manager

  validates :email, uniqueness: true
  validates_format_of :email, with: Devise::email_regexp
  validates :password, presence: true, if: -> { id.nil? }
  validates :real_name, presence: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  # live = undeleted users
  scope :live, -> { where(deleted: false) }

  def active_for_authentication?
    super && !deleted
  end

  def destroy
    update_attributes(
      deleted: true,
      deleted_at: Time.now,
      deleted_by: Current.user.id
    ) unless deleted?
  end

  def link_to_text
    "#{real_name} (#{email})"
  end
end
