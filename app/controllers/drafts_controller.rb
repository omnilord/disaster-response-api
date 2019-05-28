class DraftsController < ApplicationController
  include PageSetup
  include Polymorphable

  before_action :signed_in!
  before_action :set_draftable, only: %i[index]
  before_action :manageable!, only: %i[index edit update]
  before_action :set_draft, only: %i[show edit update destroy]
  before_action :check_drafter_access!, only: %i[show destroy]

  page :index, create: false, page: 'drafts_index',
                             content: I18n.t(:press_edit, type: 'page')

  def index
    @drafts =
      begin
        if @draftable
          Draft.actionable.where(draftable: @draftable)
        elsif params[:type].present? && params[:type].constantize
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

  def set_draftable
    @draftable ||= find_polymorph
  end

  def manageable!
    admin! unless user_signed_in?
  end

  def set_draft
    @draft = Draft.find(params[:id])
  end

  def check_drafter_access!
    return if @draftable&.manager?(Current.user)
    admin! unless @draft&.user_id == Current.user.id
  end
end
