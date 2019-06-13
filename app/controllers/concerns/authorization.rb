module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method %i[signed_in! trusted? trusted! admin? admin!]
  end

private

  def signed_in!
    unless user_signed_in?
      redirect_to request.referrer || root_path, notice: I18n.t(:please_sign_in)
    end
  end

  def trusted?
    user_signed_in? && (Current.user.admin? || Current.user.trusted?)
  end

  def trusted!
    unless trusted?
      redirect_to request.referrer || root_path, notice: I18n.t(:permission_denied)
    end
  end

  def admin?
    user_signed_in? && Current.user.admin?
  end

  def admin!
    unless admin?
      redirect_to request.referrer || root_path, notice: I18n.t(:permission_denied)
    end
  end
end
