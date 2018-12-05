class Draft < ApplicationRecord
  EDIT_REJECTION = /(?:id|_at)\z/

  belongs_to :draftable, polymorphic: true, optional: true
  belongs_to :user, optional: true, default: -> { Current.user }
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :denied_by, class_name: 'User', optional: true

  validate :draftable_edited?, on: :create

  scope :actionable, -> { includes(:draftable).where(approved_by: nil, denied_by: nil) }
  scope :actionable_by_type, ->(type) { actionable.where(draftable_type: type) }
  scope :denied, -> { where.not(denied_by: nil) }
  scope :approved, -> { where.not(approved_by: nil) }
  scope :historic, -> { denied.or(approved) }

  def build_record
    if draftable
      self.draftable.assign_attributes(data)
    else
      self.draftable = self.draftable_type.constantize.new(data)
    end
    self.draftable.current_draft_id = self.id
  end

  def deny
    update(denied_by: Current.user, denied_at: Time.now)
  end

  def approve
    build_record
    if draftable.save
      update(draftable: draftable, approved_by: Current.user, approved_at: draftable.updated_at)
    end
  end

private

  def draftable_edited?
    na = self.draftable.nil?
    t = self.draftable_type

    build_record
    if self.draftable.changes.keys.reject { |k| k.to_s.match?(EDIT_REJECTION) }.empty?
      errors.add(:base, I18n.t(:must_edit_to_save, type: self.draftable.class.name));
    end

    if na
      self.draftable = nil
      self.draftable_type = t
    else
      self.draftable.reload
    end
  end
end
