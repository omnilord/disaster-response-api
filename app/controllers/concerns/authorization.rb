module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :admin?, :admin!
  end

private

  def admin?
    user_signed_in? && Current.user.admin?
  end

  def admin!
    unless admin?
      redirect_to request.referrer || root_path, notice: 'Permission denied.'
    end
  end
end
