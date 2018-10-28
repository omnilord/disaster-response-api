require 'test_helper'

class DraftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @draft = drafts(:one)
  end

  test "should get index" do
    get drafts_url
    assert_response :success
  end

  test "should show draft" do
    get draft_url(@draft)
    assert_response :success
  end

  test "should destroy draft" do
    assert_difference('Draft.count', -1) do
      delete draft_url(@draft)
    end

    assert_redirected_to drafts_url
  end
end
