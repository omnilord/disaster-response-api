module PageSetup
  extend ActiveSupport::Concern

  ALLOWED = %w[index new edit show].freeze
  SINGULAR = %w[new edit show].freeze

  included do

    #
    # Find or Create pages outside the RESTful scope
    #
    def self.page(action, **options)
      options[:page] ||= action.to_s

      before_params = options.delete(:before_params) || {}
      before_params[:if] ||= ->(c) { c.action_name == action.to_s }

      before_action **before_params do |c|
        render_not_found if options[:require_login] && !c.user_signed_in?

        page =
          if options[:use_param].present?
            params[options[:use_param]]
          else
            options[:page]
          end
        @site_page = Page.find_or_default(page, options)
      rescue ActiveRecord::RecordNotFound => ex
        render_not_found
      end
    end


    #
    # Find or Create pages for RESTful targets
    #
    def self.resource_pages(**options)
      options[:create] = true

      before_params = options.delete(:before_params) || {}
      before_params[:if] ||= ->(c) { PageSetup::ALLOWED.include?(c.action_name) }

      before_action **before_params do |c|
        page = "#{controller_name}_#{action_name}"
        opts = options.dup
        opts[:title] =
          if PageSetup::SINGULAR.include?(action_name)
            "#{action_name} #{controller_name.singularize}".titleize
          end
        @site_page ||= Page.find_or_default(page, opts)
      end
    end
  end
end
