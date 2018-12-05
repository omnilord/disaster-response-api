class DraftsController < ApplicationController
  include PageSetup

  before_action :signed_in!
  before_action :admin!, only: %i[index edit update]
  before_action :set_draft, only: %i[show edit update destroy]
  before_action :check_drafter_access!, only: %i[show destroy]

  page :index, create: true, page: 'drafts_index',
                             content: I18n.t(:press_edit, type: 'page')

  def index
    @drafts =
      begin
        if params[:type].present? && params[:type].constantize
          Draft.actionable_by_type(params[:type])
        else
          Draft.actionable
        end
      rescue NameError
        []
      end
      .group_by(&:draftable).sort do |a, b|
        1 if a[0].nil?
        -1 if b[0].nil?
        a[0].class.name <=> b[0].class.name
      end
  end

  def show
  end

  def edit
  end

  def update
    @draft.approve
    type = @draft.draftable.class.name
    respond_to do |format|
      format.html { redirect_to drafts_path, notice: I18n.t(:draft_updated, type: type) }
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
    def set_draft
      @draft = Draft.find(params[:id])
    end

    def check_drafter_access!
      admin! unless @draft&.user_id == Current.user.id
    end
end
