module Draftable
  extend ActiveSupport::Concern

  included do
    raise 'Woah there, partner!  You cannot include Draftable on Draft!' if self.class.name == 'Draft'

    has_many :drafts, as: :draftable
    #has_one :current_draft, class_name: 'Draft'

    scope :pending_drafts, -> { drafts.active.order(created_at: :desc) }
    scope :historic_drafts, -> { drafts.historic.order(created_at: :desc) }

    # Deny outstanding drafts since the root object is destroyed
    after_destroy do |obj|
      obj.drafts.actionable.each(&:deny)
    end
  end

  def draft_type
    raise 'Draftables must define #draft_type'
  end

  def draft_approver?(user)
    raise 'Draftables must define #draft_approver?(user)'
  end

  def current_draft
    Draft.find(current_draft_id) unless current_draft_id.nil?
  end

  def pending_drafts?
    pending_drafts.count > 0
  end
end
