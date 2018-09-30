module NavbarSetup
  extend ActiveSupport::Concern

  included do
    helper_method :left_navbar_partial
  end

  def left_navbar_partial
    if admin?
      'application/navbars/admin'
    elsif user_signed_in?
      'application/navbars/user'
    else
      'application/navbars/guest'
    end
  end
end
