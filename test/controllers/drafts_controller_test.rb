require 'test_helper'

class DraftsControllerTest < DevisedTest
  #
  # Access Drafts Index Page
  #

  test 'Anonymous users cannot access drafts index' do
    get drafts_path
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Generic users cannot access drafts index' do
    sign_in users(:generic_one)
    get drafts_path
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Admin users can see drafts index' do
    sign_in users(:admin)
    get drafts_path
    assert_response :success
  end

  test 'Only actionable drafts are listed in the index' do
    # TODO: Determine if this is actually a system test or not
    skip
  end

  #
  # Access Draft View
  #

  test 'Anonymous users cannot access draft views' do
    get draft_path(drafts(:page_one))
    assert_response :redirect
    assert_redirected_to root_path

    get draft_path(drafts(:page_three))
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Generic users can see their drafts' do
    sign_in users(:generic_one)
    get draft_path(drafts(:page_three))
    assert_response :success
  end

  test 'Generic users cannot see drafts from other users' do
    sign_in users(:generic_one)
    get draft_path(drafts(:page_one))
    assert_response :redirect
    assert_redirected_to root_path

    get draft_path(drafts(:page_five))
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Admin users can see all drafts' do
    sign_in users(:admin)
    drafts.each do |draft|
      get draft_path(draft)
      assert_response :success
    end
  end

  #
  # Approve Drafts
  #

  test 'Anonymous users cannot approve drafts' do
    page_three = drafts(:page_three)
    assert_no_changes('page_three.attributes') do
      assert_no_changes('page_three.draftable.attributes') do
        patch draft_path(page_three)
        assert_response :redirect
        assert_redirected_to root_path
        page_three.reload
      end
    end
  end

  test 'Generic users cannot approve their own drafts' do
    sign_in users(:generic_one)
    page_three = drafts(:page_three)
    assert_no_changes('page_three.attributes') do
      assert_no_changes('page_three.draftable.attributes') do
        patch draft_path(page_three)
        assert_response :redirect
        assert_redirected_to root_path
        page_three.reload
      end
    end
  end

  test 'Generic users cannot approve other drafts' do
    sign_in users(:generic_one)
    page_five = drafts(:page_five)
    assert_no_changes('page_five.attributes') do
      assert_difference('Page.count', 0) do
        patch draft_path(page_five)
        assert_response :redirect
        assert_redirected_to root_path
        page_five.reload
      end
    end
  end

  test 'Admin users can approve drafts' do
    sign_in users(:admin)
    page_three = drafts(:page_three)
    patch draft_path(page_three)
    assert_response :redirect
    assert_redirected_to drafts_path

    page_five = drafts(:page_five)
    patch draft_path(page_five)
    assert_response :redirect
    assert_redirected_to drafts_path
  end


  test 'When admin users approve, existing resources get updated' do
    sign_in users(:admin)
    page_three = drafts(:page_three)
    assert_changes('page_three.attributes') do
      assert_changes('page_three.draftable.attributes') do
        patch draft_path(page_three)
        assert_response :redirect
        assert_redirected_to drafts_path
        page_three.reload
      end
    end
    assert_equal page_three.approved_by, users(:admin)
    assert_not_nil page_three.approved_at
  end

  test 'When admin users approve, new resources get created' do
    sign_in users(:admin)
    page_five = drafts(:page_five)
    assert_changes('page_five.attributes') do
      assert_difference('Page.count', 1) do
        patch draft_path(page_five)
        assert_response :redirect
        assert_redirected_to drafts_path
        page_five.reload
      end
    end
    assert_equal page_five.approved_by, users(:admin)
    assert_not_nil page_five.approved_at
  end

  test 'Approved drafts are removed from the drafts index list' do
    # TODO: Determine if this is actually a system test or not
    skip
  end

  #
  # Deny Drafts
  #
  #
  test 'Anonymous users cannot deny drafts' do
    page_three = drafts(:page_three)
    assert_no_changes('page_three.attributes') do
      assert_no_changes('page_three.draftable.attributes') do
        delete draft_path(page_three)
        assert_response :redirect
        assert_redirected_to root_path
        page_three.reload
      end
    end
  end

  test 'Generic users can deny their own drafts to existing resources' do
    sign_in users(:generic_one)
    page_three = drafts(:page_three)
    assert_changes('page_three.attributes') do
      assert_no_changes('page_three.draftable.attributes') do
        delete draft_path(page_three)
        assert_response :redirect
        assert_redirected_to draft_path(page_three)
        page_three.reload
      end
    end
    assert_equal page_three.denied_by, users(:generic_one)
    assert_not_nil page_three.denied_at
  end

  test 'Generic users can deny their own drafts to create new resources' do
    sign_in users(:generic_two)
    page_five = drafts(:page_five)
    assert_changes('page_five.attributes') do
      assert_difference('Page.count', 0) do
        delete draft_path(page_five)
        assert_response :redirect
        assert_redirected_to draft_path(page_five)
        page_five.reload
      end
    end
    assert_equal page_five.denied_by, users(:generic_two)
    assert_not_nil page_five.denied_at
  end

  test 'Generic users cannot deny other drafts' do
    sign_in users(:generic_one)
    page_five = drafts(:page_five)
    assert_no_changes('page_five.attributes') do
      assert_difference('Page.count', 0) do
        delete draft_path(page_five)
        assert_response :redirect
        assert_redirected_to root_path
        page_five.reload
      end
    end
  end

  test 'Admin users can deny drafts to existing resources' do
    sign_in users(:admin)
    page_three = drafts(:page_three)
    assert_changes('page_three.attributes') do
      assert_no_changes('page_three.draftable.attributes') do
        delete draft_path(page_three)
        assert_response :redirect
        assert_redirected_to drafts_path
        page_three.reload
      end
    end
    assert_equal page_three.denied_by, users(:admin)
    assert_not_nil page_three.denied_at
  end

  test 'Admin users can deny drafts to create new resources' do
    sign_in users(:admin)
    page_five = drafts(:page_five)
    assert_changes('page_five.attributes') do
      assert_difference('Page.count', 0) do
        delete draft_path(page_five)
        assert_response :redirect
        assert_redirected_to drafts_path
        page_five.reload
      end
    end
    assert_equal page_five.denied_by, users(:admin)
    assert_not_nil page_five.denied_at
  end

  test 'Denied drafts are removed from the drafts index list' do
    # TODO: Determine if this is actually a system test or not
    skip
  end

  # TODO: Do the next two tests require all users testing?
  test 'Approving previously approved/denied drafts fails' do
    skip
  end

  test 'Denying previously approved/denied drafts fails' do
    skip
  end

  # TODO features: Draft editing,
  #                Review history of drafts for a resource,
  #                Revert to past draft / replace with an old draft

  test 'Anonymous users cannot edit drafts' do
    skip
  end

  test 'Generic users cannot edit drafts from other users' do
    skip
  end

  test 'Generic users can edit their own drafts' do
    skip
  end

  test 'Admin users can edit all drafts' do
    skip
  end

  test 'Edited drafts are approved on save and replaced by a new draft of the edits' do
    skip
  end

  test 'Saving without changes just approves the draft' do
    skip
  end
end
