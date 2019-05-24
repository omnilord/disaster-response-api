class Page < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  include Draftable

  belongs_to :created_by, class_name: 'User', default: -> { Current.user }
  belongs_to :updated_by, class_name: 'User', default: -> { Current.user }

  before_save :sanitize!
  before_save -> { self.updated_by = Current.user }

  def self.find_or_default(pagename, **options)
    page = where(page: pagename).first
    if page.nil?
      page_data = {
        page: pagename,
        title: options[:title] || pagename.titleize,
        content: options[:content] || ''
      }
      if options[:create]
        draft = Draft.create(draftable_type: Page,
                             approved_by: Current.user,
                             data: page_data)
        draft.approve
        draft.draftable
      else
        Page.new(page_data)
      end
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

  def draft_approver?(user)
    user&.admin?
  end

private

  def sanitize!
    self.title = sanitize(self.title)
    self.content = sanitize(self.content, tags: ALLOWED_HTML_TAGS, attributes: ALLOWED_HTML_ATTRIBUTES)
  end
end
