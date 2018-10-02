class PagesController < ApplicationController
  include PageSetup

  before_action :admin!, except: [:show]

  before_action :set_page, only: [:edit, :update, :destroy]

  page :show, use_param: :page, content: 'Press "Edit" to update this page.'
  resource_pages mode: :permissive, create: false

  def index
    @pages = Page.all
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)
    if @page.save
      redirect_to pages_path, notice: "`#{@page.page}` page was successfully created."
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @page.update(page_params)
      redirect_to pages_path, notice: 'Page was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @page.destroy
    redirect_to pages_path, notice: 'Page was successfully destroyed.'
  end

private

  def set_page
    @page = Page.where(page: params[:page]).first if params[:page].is_a?(String)
    @page ||= Page.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = 'No page with that name or id'
    redirect_to root_path && return
  end

  def page_params
    params.require(:page).permit(:page, :title, :content)
  end
end
