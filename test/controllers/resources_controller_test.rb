require 'test_helper'
require 'minitest/spec'

class ResourcesControllerTest < DevisedTest
  extend Minitest::Spec::DSL

  let(:params) do
    {
      resource: {
        name: 'Charitable Donations',
        resource_type: 'pod',
        address: '123 Test Street',
        city: 'Test',
        state: 'DE',
        postal_code: '19713',
        county: 'New Castle County'
      }
    }
  end

  let(:shelter) do
    resources(:shelter_one)
  end

  #
  # anyone should be able to see resources
  #

  test 'anonymous user should get resource index' do
    get resources_path
    assert_response :success
  end

  test 'generic user should get resource index' do
    sign_in users(:generic_one)
    get resources_path
    assert_response :success
  end

  test 'trusted user should get resource index' do
    sign_in users(:trusted)
    get resources_path
    assert_response :success
  end

  test 'admin user should get resource index' do
    sign_in users(:admin)
    get resources_path
    assert_response :success
  end

  test 'anonymous users can see individual resources' do
    get resource_path(shelter)
    assert_response :success
  end

  test 'generic users can see individual resources' do
    sign_in users(:generic_one)
    get resource_path(shelter)
    assert_response :success
  end

  test 'trusted users can see individual resources' do
    sign_in users(:trusted)
    get resource_path(shelter)
    assert_response :success
  end

  test 'admin users can see individual resources' do
    sign_in users(:admin)
    get resource_path(shelter)
    assert_response :success
  end

  #
  # only trusted users (includes admin users) should be able to mutate resources
  #

  test 'anonymous users should not get new' do
    get new_resource_path
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'generic users can get new' do
    sign_in users(:generic_one)
    get new_resource_path
    assert_response :success
  end

  test 'trusted users can get new' do
    sign_in users(:trusted)
    get new_resource_path
    assert_response :success
  end

  test 'admin users can get new' do
    sign_in users(:admin)
    get new_resource_path
    assert_response :success
  end

  test 'anonymous users should not create resource' do
    assert_difference('Draft.count', 0) do
      assert_difference('Resource.count', 0) do
        post resources_path, params: params
        assert_response :redirect
        assert_redirected_to root_path
      end
    end
  end


  test 'generic users should create a draft resource' do
    sign_in users(:generic_one)
    assert_difference('Draft.count', 1) do
      assert_difference('Resource.count', 0) do
        post resources_path, params: params
        assert_response :redirect
        assert_redirected_to draft_path(Draft.last)
      end
    end
  end

  test 'trusted users should create a draft and resource' do
    sign_in users(:trusted)
    assert_difference('Draft.count', 1) do
      assert_difference('Resource.count', 1) do
        post resources_path, params: params
        assert_response :redirect
        assert_redirected_to resource_path(Resource.last)
      end
    end
  end

  test 'admin users should create a draft and resource' do
    sign_in users(:admin)
    assert_difference('Draft.count', 1) do
      assert_difference('Resource.count', 1) do
        post resources_path, params: params
        assert_response :redirect
        assert_redirected_to resource_path(Resource.last)
      end
    end
  end

  #
  # Trusted users can edit and save resources
  #   other users will create drafts
  #

  test 'anonymous users should not get edit' do
    get edit_resource_path(shelter)
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'generic users can get edit' do
    sign_in users(:generic_one)
    get edit_resource_path(shelter)
    assert_response :success
  end

  test 'trusted users can get edit' do
    sign_in users(:trusted)
    get edit_resource_path(shelter)
    assert_response :success
  end

  test 'admin users can get edit' do
    sign_in users(:admin)
    get edit_resource_path(shelter)
    assert_response :success
  end

  test 'anonymous users should not update resource' do
    patch resource_path(shelter), params: params
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Generic users only create a draft when updating resources' do
    resource = shelter
    sign_in users(:generic_one)
    assert_difference('Draft.count', 1) do
      assert_difference('Resource.count', 0) do
        assert_no_changes('resource.attributes') do
          patch resource_path(resource), params: params
          assert_response :redirect
          resource.reload
          assert_redirected_to draft_path(resource.drafts.last)
        end
      end
    end
  end

  test 'Trusted users create and apply a draft when updating resources' do
    resource = shelter
    comp = lambda do
      {
        name: resource.name,
        resource_type: resource.resource_type,
        address: resource.address,
        city: resource.city,
        state: resource.state,
        postal_code: resource.postal_code,
        county: resource.county
      }
    end


    sign_in users(:trusted)
    assert_difference('Draft.count', 1) do
      assert_difference('Resource.count', 0) do
        assert_changes(comp,
                       from: comp.call,
                       to: params[:resource]) do
          patch resource_path(resource), params: params
          assert_response :redirect
          resource.reload
          assert_equal users(:trusted), resource.current_draft.user
          assert_redirected_to resource_path(resource)
        end
      end
    end
  end

  test 'Admin users create and apply a draft when updating resources' do
    resource = shelter
    comp = lambda do
      {
        name: resource.name,
        resource_type: resource.resource_type,
        address: resource.address,
        city: resource.city,
        state: resource.state,
        postal_code: resource.postal_code,
        county: resource.county
      }
    end

    sign_in users(:admin)
    assert_difference('Draft.count', 1) do
      assert_difference('Resource.count', 0) do
        assert_changes(comp,
                       from: comp.call,
                       to: params[:resource]) do
          patch resource_path(resource), params: params
          assert_response :redirect
          resource.reload
          assert_equal users(:admin), resource.current_draft.user
          assert_redirected_to resource_path(resource)
        end
      end
    end
  end
end
