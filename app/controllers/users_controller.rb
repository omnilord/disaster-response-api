class UsersController < ApplicationController
  include PageSetup

  before_action :admin!

  resource_pages create: true, content: I18n.t(:press_edit, type: I18n.t(:page))

  def index
    @users = User.order(:id).all
  end
end
