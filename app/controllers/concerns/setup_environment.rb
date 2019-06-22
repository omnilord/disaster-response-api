module SetupEnvironment
  extend ActiveSupport::Concern

  included do
    before_action :setup_env

    helper_method :site_title, :display_username
  end

  def site_title
    @site_title
  end

  def display_username
    @username
  end

private

  def setup_env
    @site_title = ENV.fetch('site_title', I18n.t(:site_title))
    @username = user_signed_in? ? current_user.real_name : 'Guest'
    Current.user = current_user
  end
end
