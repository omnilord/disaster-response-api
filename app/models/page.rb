class Page < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include Draftable

  belongs_to :editor, class_name: 'User', optional: true, default: -> { Current.user }

  before_save :sanitize!
  before_save -> { self.editor = Current.user }

  def self.find_or_default(page, **options)
    if options[:create]
      where(page: page).first_or_create do |p|
        p.title = options[:title] || page.titleize
        p.content = options[:content] || ''
        p.drafts << Draft.create(draftable_type: Page,
                                 approved_by: Current.user, approved_at: p.created_at,
                                 data: { page: p.page, title: p.title, content: p.content })
        p.current_draft_id = p.drafts.last.id
      end
    else
      find_by!(page: page)
    end
  end

  def link_to_text
    "#{title} (#{page})"
  end

private

  def sanitize!
    self.title = sanitize(self.title)
    self.content = sanitize(self.content, tags: ALLOWED_HTML_TAGS, attributes: ALLOWED_HTML_ATTRIBUTES)
  end
end
