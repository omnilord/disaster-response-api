class PagesController < ApplicationController
  include PageSetup
  include DraftHandler

  before_action :signed_in!, except: [:page]
  before_action :admin!, only: [:destroy]
  before_action :set_page, only: [:show, :edit, :update, :destroy]
  before_action :set_draft_count_warning, only: [:edit]

  page :page, use_param: :page, create: true, content: I18n.t(:press_edit, type: I18n.t(:page))
  resource_pages create: true

  def index
    @pages = Page.all
  end

  def new
    @page = Page.new
  end

  def create
    save_or_draft(:create)
  end

  def page
  end

  def show
  end

  def edit
  end

  def update
    save_or_draft(:update)
  end

  def destroy
    @page.destroy
    redirect_to pages_path, notice: I18n.t(:destroy_success, type: I18n.t(:page))
  end

private

  def set_page
    @page = Page.where(page: params[:page]).first if params[:page].is_a?(String)
    @page ||= Page.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t(:rest_404, type: I18n.t(:page))
    redirect_to root_path && return
  end

  def page_params
    @page_parameters ||= params.require(:page).permit(:id, :page, :title, :content)
  end
end
