# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!


ALLOWED_HTML_TAGS = %w[div span img i p a h1 h2 h3 h4 h5 h6 em q i b sub sup small mark del ins strong ul ol li blockquote code pre s dl dt dd table thead tbody th tr td].freeze

ALLOWED_HTML_ATTRIBUTES = %w[style class src href alt]
