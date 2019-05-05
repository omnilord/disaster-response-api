class UsersController < ApplicationController
  include PageSetup

  before_action :admin!
  before_action :set_user, only: %i[show edit update destroy]

  resource_pages create: true

  def index
    @users = User.order(:last_sign_in_at).all
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user
    else
      flash[:danger] = @user.errors.full_messages
      redirect_to edit_user(@user)
    end
  end

  def destroy
    if @user.id == 1
      redirect_to @user, danger: 'Cannot delete root admin.'
    else
      @user.deleted = true
      if @user.save
        redirect_to users_path, warning: "#{@user.link_to_text} has been soft deleted."
      else
        redirect_to @user, danger: @user.errors.full_messages
      end
    end
  end

private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :real_name, :location, :time_zone, :admin, :deleted)
  end
end
