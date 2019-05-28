require 'test_helper'

class PagesControllerTest < DevisedTest
  #
  # Certain pages will default to a specific value when loaded the first time
  #   root_path is a good example of a page that will do this.
  #

  test 'Loading pages anonymous does not create default pages' do
    assert_difference('Draft.count', 0) do
      assert_difference('Page.count', 0) do
        get root_path
        assert_response :success
      end
    end
  end

  test 'Loading pages as a generic user does not create default pages' do
    assert_difference('Draft.count', 0) do
      assert_difference('Page.count', 0) do
        sign_in users(:generic_one)
        get root_path
        assert_response :success
      end
    end
  end

  test 'Loading index as an admin user does not create default pages' do
    assert_difference('Draft.count', 0) do
      assert_difference('Page.count', 0) do
        sign_in users(:admin)
        get root_path
        assert_response :success
      end
    end
  end

  #
  # Admin and generic users should have access to pages index.
  #

  test 'Anonymous users cannot view pages index' do
    get pages_path
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Generic users can view pages index' do
    sign_in users(:generic_one)
    get pages_path
    assert_response :success
  end

  test 'Admin users can view pages index' do
    sign_in users(:admin)
    get pages_path
    assert_response :success
  end

  #
  # Creating a new page has specific behaviors
  #

  test 'Anonymous users are redirected from creating new pages' do
    get new_page_path
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Generic users can access new page route' do
    sign_in users(:generic_one)
    get new_page_path
    assert_response :success
  end

  test 'Admin users can access new page route' do
    sign_in users(:admin)
    get new_page_path
    assert_response :success
  end

  test 'Anonymous users are prohibited from creating new pages' do
    params = {
      page: {
        page: 'Foobar',
        title: 'Foo Bar Baz',
        content: 'No Lorem Ipsum here.'
      }
    }

    assert_difference('Draft.count', 0) do
      assert_difference('Page.count', 0) do
        post pages_path, params: params
        assert_response :redirect
        assert_redirected_to root_path
      end
    end
  end

  test 'Generic users only create a draft when submitting a new page' do
    params = {
      page: {
        page: 'Foobar',
        title: 'Foo Bar Baz',
        content: 'No Lorem Ipsum here.'
      }
    }

    sign_in users(:generic_one)
    assert_difference('Draft.count', 1) do
      assert_difference('Page.count', 0) do
        post pages_path, params: params
        assert_response :redirect
        assert_redirected_to draft_path(Draft.last)
      end
    end
  end

  test 'New draft contain fields as submitted' do
    params = {
      page: {
        page: 'Foobar',
        title: 'Foo Bar Baz',
        content: 'No Lorem Ipsum here.'
      }
    }

    sign_in users(:generic_one)
    post pages_path, params: params
    page = Page.last
    draft = Draft.last
    assert_equal params[:page][:page], draft.data['page']
    assert_not_equal params[:page][:page], page.page
    assert_equal params[:page][:title], draft.data['title']
    assert_not_equal params[:page][:title], page.title
    assert_equal params[:page][:content], draft.data['content']
    assert_not_equal params[:page][:content], page.content
    assert_equal users(:generic_one), draft.user
    assert_nil draft.approved_by
    assert_nil draft.denied_by
    assert_not_equal draft.id, page.current_draft_id
  end

  test 'Admin users create both a draft and a page when submitting a new page' do
    params = {
      page: {
        page: 'Foobar',
        title: 'Foo Bar Baz',
        content: 'No Lorem Ipsum here.'
      }
    }

    sign_in users(:admin)
    assert_difference('Draft.count', 1) do
      assert_difference('Page.count', 1) do
        post pages_path, params: params
        assert_response :redirect
        assert_redirected_to page_path(Page.last)
      end
    end
  end

  test 'New pages contain fields as submitted' do
    params = {
      page: {
        page: 'Foobar',
        title: 'Foo Bar Baz',
        content: 'No Lorem Ipsum here.'
      }
    }

    sign_in users(:admin)
    post pages_path, params: params
    page = Page.last
    draft = Draft.last
    assert_equal params[:page][:page], draft.data['page']
    assert_equal params[:page][:page], page.page
    assert_equal params[:page][:title], draft.data['title']
    assert_equal params[:page][:title], page.title
    assert_equal params[:page][:content], draft.data['content']
    assert_equal params[:page][:content], page.content
    assert_equal users(:admin), draft.user
    assert_equal users(:admin), draft.approved_by
    assert_nil draft.denied_by
    assert_equal users(:admin), page.current_draft.user
    assert_equal draft.id, page.current_draft_id
  end

  #
  # Editing existing pages has specific behaviors
  #

  test 'Anonymous users are redirected from editing pages' do
    get edit_page_path(pages(:lorem))
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Generic users can access editing pages' do
    sign_in users(:generic_one)
    get edit_page_path(pages(:lorem))
    assert_response :success
  end

  test 'Admin users can access editing pages' do
    sign_in users(:admin)
    get edit_page_path(pages(:lorem))
    assert_response :success
  end

  test 'Anonymous users are prohibited from updating pages' do
    page = pages(:lorem)
    params = {
      page: {
        page: page.page,
        title: 'This is a New Title Now',
        content: 'No longer Lorem Ipsum.'
      }
    }

    assert_difference('Draft.count', 0) do
      assert_difference('Page.count', 0) do
        assert_no_changes('page.attributes') do
          patch page_path(page), params: params
          assert_response :redirect
          assert_redirected_to root_path
          page.reload
        end
      end
    end
  end

  test 'Generic users only create a draft when updating pages' do
    page = pages(:lorem)
    params = {
      page: {
        page: page.page,
        title: 'This is a New Title Now',
        content: 'No longer Lorem Ipsum.'
      }
    }

    sign_in users(:generic_one)
    assert_difference('Draft.count', 1) do
      assert_difference('Page.count', 0) do
        assert_no_changes('page.attributes') do
          patch page_path(page), params: params
          assert_response :redirect
          page.reload
          assert_redirected_to draft_path(page.drafts.last)
        end
      end
    end
  end

  test 'Admin users create and apply a draft when updating pages' do
    page = pages(:lorem)
    comp = lambda do
      { page: page.page, title: page.title, content: page.content }
    end
    params = {
      page: {
        page: page.page,
        title: 'This is a New Title Now',
        content: 'No longer Lorem Ipsum.'
      }
    }

    sign_in users(:admin)
    assert_difference('Draft.count', 1) do
      assert_difference('Page.count', 0) do
        assert_changes(comp,
                       from: comp.call,
                       to: params[:page]) do
          patch page_path(page), params: params
          assert_response :redirect
          page.reload
          assert_equal users(:admin), page.current_draft.user
          assert_redirected_to page_path(page)
        end
      end
    end
  end

  # TODO: Test Deleting pages

  # TODO: Advanced testing - Test field sanitizing works properly (markdown passes through, scripts do not)
end
