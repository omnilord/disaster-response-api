require "application_system_test_case"

class DraftsTest < ApplicationSystemTestCase
  setup do
    @draft = drafts(:one)
  end

  test "visiting the index" do
    visit drafts_url
    assert_selector "h1", text: "Drafts"
  end

  test "destroying a Draft" do
    visit drafts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Draft was successfully destroyed"
  end
end
