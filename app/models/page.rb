class Page < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper

  belongs_to :editor, class_name: 'User', optional: true, default: -> { Current.user }

  before_save :sanitize!
  before_save -> { self.editor = Current.user }

  scope :find_or_default, ->(page, **options) do
    if options[:create]
      call = Current.user.nil? || options[:no_create] ? :first_or_initialize : :first_or_create
      where(page: page).send(call) do |p|
        p.title = options[:title] || page.titleize
        p.content = options[:content] || ''
      end
    else
      find_by!(page: page)
    end
  end

private

  def sanitize!
    self.title = sanitize(self.title)
    self.content = sanitize(self.content, tags: ALLOWED_HTML_TAGS, attributes: ALLOWED_HTML_ATTRIBUTES)
  end
end
