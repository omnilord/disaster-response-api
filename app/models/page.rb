class Page < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include Draftable

  belongs_to :editor, class_name: 'User', optional: true, default: -> { Current.user }

  before_save :sanitize!
  before_save -> { self.editor = Current.user }

  def self.find_or_default(pagename, **options)
    page = where(page: pagename).first
    if page.nil? && options[:create]
      draft = Draft.create(draftable_type: Page,
                           approved_by: Current.user,
                           data: {
                             page: pagename,
                             title: options[:title] || pagename.titleize,
                             content: options[:content] || ''
                           })
      draft.approve
      draft.draftable
    else
      page
    end
  end

  def link_to_text
    "#{title} (#{page})"
  end

  def draft_type
    page
  end

private

  def sanitize!
    self.title = sanitize(self.title)
    self.content = sanitize(self.content, tags: ALLOWED_HTML_TAGS, attributes: ALLOWED_HTML_ATTRIBUTES)
  end
end
