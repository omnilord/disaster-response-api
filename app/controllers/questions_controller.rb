class QuestionsController < ApplicationController
  include PageSetup
  include DraftHandler

  before_action :set_question, only: %i[show edit update destroy]
  before_action :signed_in!, only: %i[new create edit update]
  before_action :trusted!, only: %i[destroy]
  before_action :set_draft_count_warning, only: %i[edit]

  resource_pages

  def index
    @questions = Question.all
  end

  def new
    @question = Question.new
  end

  def create
    save_or_draft :create
  end

  def edit
  end

  def show
  end

  def update
    save_or_draft :update
  end

  def destroy
    @question.destroy
    redirect_to questions_path, notice: I18n.t(:destroy_success, type: I18n.t(:question))
  end

private

  def set_question
    @question = Question.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def question_params
    params.require(:question).permit(:content, :active)
  end
end
