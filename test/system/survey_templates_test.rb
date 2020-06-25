require "application_system_test_case"

class SurveyTemplatesTest < ApplicationSystemTestCase
  setup do
    @survey_template = survey_templates(:one)
  end

  test "visiting the index" do
    visit survey_templates_url
    assert_selector "h1", text: "Survey Templates"
  end

  test "creating a Survey template" do
    visit survey_templates_url
    click_on "New Survey Template"

    fill_in "Created by", with: @survey_template.created_by_id
    fill_in "Current draft", with: @survey_template.current_draft_id
    fill_in "Notes", with: @survey_template.notes
    fill_in "Resource type", with: @survey_template.resource_type
    fill_in "Updated by", with: @survey_template.updated_by_id
    click_on "Create Survey template"

    assert_text "Survey template was successfully created"
    click_on "Back"
  end

  test "updating a Survey template" do
    visit survey_templates_url
    click_on "Edit", match: :first

    fill_in "Created by", with: @survey_template.created_by_id
    fill_in "Current draft", with: @survey_template.current_draft_id
    fill_in "Notes", with: @survey_template.notes
    fill_in "Resource type", with: @survey_template.resource_type
    fill_in "Updated by", with: @survey_template.updated_by_id
    click_on "Update Survey template"

    assert_text "Survey template was successfully updated"
    click_on "Back"
  end

  test "destroying a Survey template" do
    visit survey_templates_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Survey template was successfully destroyed"
  end
end
