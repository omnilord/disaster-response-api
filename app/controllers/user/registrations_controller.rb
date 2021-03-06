class User::RegistrationsController < Devise::RegistrationsController

private

  def sign_up_params
    params.require(:user).permit(:email, :real_name, :time_zone, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:email, :real_name, :time_zone, :password, :password_confirmation, :current_password)
  end
end
