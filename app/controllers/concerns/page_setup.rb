module PageSetup
  extend ActiveSupport::Concern

  DISALLOWED = %w[create update destroy].freeze
  SINGULAR = %w[new edit show].freeze


  included do
    def self.page(action, **options)
      options[:page] ||= action.to_s

      before_params = options.delete(:before_params) || {}
      before_params[:if] ||= ->(c) { c.action_name == options[:page] }

      before_action **before_params do
        page =
          if options[:use_param].present?
            params[options[:use_param]]
          else
            options[:page]
          end
        @site_page = Page.find_or_default(page, options)
      rescue ActiveRecord::RecordNotFound => ex
        redirect_to (options[:not_found_url] || root_path)
      end
    end

    def self.resource_pages(**options)
      options[:create] = options[:create].present? ? options[:create] : true

      before_params = options.delete(:before_params) || {}
      before_params[:unless] ||= ->(c) { PageSetup::DISALLOWED.include?(c.action_name) }

      before_action **before_params do
        page = "#{controller_name}_#{action_name}"
        options[:title] =
          if SINGULAR.include?(action_name)
            "#{action_name} #{controller_name.singularize}".titleize
          end
        @site_page ||= Page.find_or_default(page, options)
      end
    end
  end
end
