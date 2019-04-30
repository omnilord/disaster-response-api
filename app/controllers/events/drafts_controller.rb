class DraftsController < ApplicationController
  include PageSetup

  before_action :signed_in!
  before_action :set_event
  before_action :event_manager?, only: %i[index edit update]
  before_action :set_draft, only: %i[show edit update destroy]
  before_action :check_drafter_access!, only: %i[show destroy]

  page :index, create: true, page: 'drafts_index',
                             content: I18n.t(:press_edit, type: 'page')

  def index
    @drafts = Draft.find_by(draftable: @event).actionable
    render 'drafts/index'
  end

  def show
  end

  def edit
  end

  def update
    @draft.approve
    type = @draft.draftable.class.name.downcase.to_sym
    respond_to do |format|
      format.html { redirect_to drafts_path, notice: I18n.t(:draft_updated, type: I18n.t(type)) }
      format.json { head :no_content, status: :ok }
    end
  end

  def destroy
    @draft.deny
    respond_to do |format|
      format.html { redirect_to admin? ? drafts_path : draft_path(@draft), notice: I18n.t(:draft_denied) }
      format.json { head :no_content, status: :ok }
    end
  end

private

  def set_event
    @event = Event.find_by(slug: params[:id])
    @event ||= Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t(:rest_404, type: I18n.t(:event))
    redirect_to root_path && return
  end

  def event_manager?
    binding.pry
    admin! unless @event.manager?(Current.user)
  end

  def set_draft
    @draft = Draft.find(params[:id])
  end

  def check_drafter_access!
    admin! unless @draft&.user_id == Current.user.id
  end
end
