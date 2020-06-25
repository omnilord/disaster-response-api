class SurveyTemplatesController < ApplicationController
  include PageSetup
  include DraftHandler

  before_action :trusted!
  before_action :set_survey_template, only: %i[show edit update]
  before_action :set_questions, only: %i[edit]
  before_action :set_draft_count_warning, only: %i[edit]

  resource_pages

  def index
    @survey_templates = SurveyTemplate.all
  end

  def show
  end

  def new
    @survey_template = SurveyTemplate.new
    @survey_template.resource_type = params[:resource_type] if Resource::TYPE_KEYS.include?(params[:resource_type]&.to_sym)
    @questions = Question.active
  end

  def edit
  end

  def create
    save_or_draft :create
  end

  def update
    save_or_draft :update
  end

private

  def set_survey_template
    @survey_template = SurveyTemplate.find(params[:id])
  end

  def set_questions
    @questions = Question.active - @survey_template.questions
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def survey_template_params
    stq_attrs = %i[id question_id position active required private]
    params.require(:survey_template)
          .permit(:resource_type, :notes,
                  survey_template_questions_attributes: stq_attrs)
          .tap do |p|
      # reject any selection that does not have an associated question
      p[:survey_template_questions_attributes].reject! { |_, stq| stq[:question_id].blank? }
    end
  end
end
