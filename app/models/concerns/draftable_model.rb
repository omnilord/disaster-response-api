module DraftableModel
  extend ActiveSupport::Concern

  included do
    raise 'Woah there, partner!  You cannot include Draftable on Draft!' if self.class.name == 'Draft'

    has_many :drafts, as: :draftable
    has_one :current_draft, class_name: 'Draft'#, optional: true

    scope :pending_drafts, -> { drafts.active.order(created_at: :desc) }
    scope :historic_drafts, -> { drafts.historic.order(created_at: :desc) }
  end

  def pending_drafts?
    pending_drafts.count > 0
  end
end
