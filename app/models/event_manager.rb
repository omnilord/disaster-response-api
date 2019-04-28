class EventManager < ApplicationRecord
  belongs_to :event
  belongs_to :user

  def toggle(value = nil)
    if value.nil?
      self[:active] = !self[:active]
    else
      self[:active] = !!value
    end
    save!
    self[:active]
  end
end
