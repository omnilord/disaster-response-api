class PagesController < ApplicationController
  include PageSetup

  before_action :signed_in!, except: [:page]
  before_action :admin!, only: [:destroy]
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  page :page, use_param: :page, create: true, content: I18n.t(:press_edit, type: 'page')
  resource_pages mode: :permissive, create: true

  def index
    @pages = Page.all
  end

  def new
    @page = Page.new
  end

  def create
    save_or_draft :create
  end

  def page
  end

  def show
  end

  def edit
  end

  def update
    save_or_draft :update
  end

  def destroy
    @page.destroy
    redirect_to pages_path, notice: I18n.t(:destroy_success, type: I18n.t(:page))
  end

private

  def save_or_draft(method)
    success, pending, error_render =
      if method == :create
        @draft = Draft.create(draftable_type: Page, data: page_params)
        [:new_success, :new_draft_pending, :new]
      else
        @draft = Draft.create(draftable: @page, data: page_params)
        [:update_success, :update_draft_pending, :edit]
      end

    if @draft
      if Current.user&.admin? && @draft.approve
        @page = @draft.draftable
        redirect_to pages_path, notice: I18n.t(success, type: "`#{@page.page}` #{I18n.t(:page)}")
      else
        redirect_to @draft, notice: I18n.t(pending, draft: I18n.t(:page))
      end
    else
      flash[:notice] = I18n.t(:generic_error)
      render error_render
    end
  end

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
