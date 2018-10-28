class DraftsController < ApplicationController
  before_action :admin!
  before_action :set_draft, only: [:show, :edit, :update, :destroy]

  def index
    @drafts = Draft.all
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @draft.update(draft_params)
        format.html { redirect_to @draft, notice: 'Draft was successfully updated.' }
        format.json { render :show, status: :ok, location: @draft }
      else
        format.html { render :edit }
        format.json { render json: @draft.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @draft.deny
    respond_to do |format|
      format.html { redirect_to drafts_url, notice: 'Draft was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_draft
      @draft = Draft.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def draft_params
      params.require(:draft).permit(:draftable_id, :draftable_type, :data, :user_id)
    end
end
