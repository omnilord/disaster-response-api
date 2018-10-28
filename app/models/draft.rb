class Draft < ApplicationRecord
  belongs_to :draftable, polymorphic: true, optional: true
  belongs_to :user, optional: true, default: -> { Current.user }
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :denied_by, class_name: 'User', optional: true

  scope :actionable, -> { where(approved_by: nil, denied_by: nil) }
  scope :actionable_by_type, ->(type) { actionable.where(draftable_type: type) }
  scope :denied, -> { where.not(denied_by: nil) }
  scope :approved, -> { where.not(approved_by: nil) }
  scope :historic, -> { denied.or(approved) }

  def build_record
    if draftable
      self.draftable.assign_attributes(data)
    else
      self.draftable = draftable_type.constantize.new(data)
    end
    self.draftable.current_draft_id = self.id
  end

  def deny
    update(denied_by: Current.user, denied_at: Time.now)
  end

  def approve
    build_record
    if draftable.save
      update(draftable: draftable, approved_by: Current.user, approved_at: draftable.created_at)
    end
  end
end
