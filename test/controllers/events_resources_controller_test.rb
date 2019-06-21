require 'test_helper'
require 'minitest/spec'

class EventsResourcesControllerTest < DevisedTest
  extend Minitest::Spec::DSL

  #
  # Edit view
  #

  test 'anonymous user should not get event resources index' do
    get event_resources_path(events(:earthquake))
    assert_response :redirect
    assert_redirected_to event_path(events(:earthquake))
  end

  test 'generic user should not get event resources index' do
    sign_in users(:generic_three)
    get event_resources_path(events(:earthquake))
    assert_response :redirect
    assert_redirected_to event_path(events(:earthquake))
  end

  test 'trusted user should get event resources index' do
    sign_in users(:trusted)
    get event_resources_path(events(:earthquake))
    assert_response :success
  end

  test 'event manager should get event resources index' do
    sign_in users(:generic_two)
    get event_resources_path(events(:earthquake))
    assert_response :success
  end

  test 'event administrator should get event resources index' do
    sign_in users(:generic_one)
    get event_resources_path(events(:earthquake))
    assert_response :success
  end

  test 'admin user should get event resources index' do
    sign_in users(:admin)
    get event_resources_path(events(:earthquake))
    assert_response :success
  end

  #
  # Add Resources
  #

  test 'anonymous user should not add event resources' do
    event = events(:earthquake)
    expected = event.resource_ids.dup.sort.freeze
    params = { event: { resource_ids: [ resources(:shelter_four).id ] } }

    assert_difference('ResourceActivation.count', 0) do
      post event_resources_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal expected, event.resource_ids.sort
    end
  end

  test 'generic user should not add event resources' do
    event = events(:earthquake)
    expected = event.resource_ids.dup.sort.freeze
    params = { event: { resource_ids: [ resources(:shelter_four).id ] } }

    sign_in users(:generic_three)
    assert_difference('ResourceActivation.count', 0) do
      post event_resources_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal expected, event.resource_ids.sort
    end
  end

  test 'event manager should add event resources' do
    event = events(:earthquake)
    expected = [*event.resource_ids.dup, resources(:shelter_four).id].sort.freeze
    params = { event: { resource_ids: [ resources(:shelter_four).id ] } }

    sign_in users(:generic_two)
    assert_difference('ResourceActivation.count', 1) do
      post event_resources_path(event), params: params
      assert_response :success
      event.reload
      assert_equal expected, event.resource_ids.sort
    end
  end

  test 'trusted user should add event resources' do
    event = events(:earthquake)
    expected = [*event.resource_ids.dup, resources(:shelter_four).id].sort.freeze
    params = { event: { resource_ids: [ resources(:shelter_four).id ] } }

    sign_in users(:trusted)
    assert_difference('ResourceActivation.count', 1) do
      post event_resources_path(event), params: params
      assert_response :success
      event.reload
      assert_equal expected, event.resource_ids.sort
    end
  end

  test 'event administrator should add one resource' do
    event = events(:earthquake)
    expected = [*event.resource_ids.dup, resources(:shelter_four).id].sort.freeze
    params = { event: { resource_ids: [ resources(:shelter_four).id ] } }

    sign_in users(:generic_one)
    assert_difference('ResourceActivation.count', 1) do
      post event_resources_path(event), params: params
      assert_response :success
      event.reload
      assert_equal expected, event.resource_ids.sort
    end
  end

  test 'event administrator should add multiple resources' do
    event = events(:earthquake)
    adding = [
      resources(:shelter_four).id,
      resources(:shelter_five).id,
      resources(:pod_four).id,
      resources(:pod_five).id,
      resources(:medsite_two).id
    ].freeze
    expected = [*event.resource_ids.dup, *adding].sort.freeze
    params = { event: { resource_ids: adding } }

    sign_in users(:generic_one)
    assert_difference('ResourceActivation.count', adding.length) do
      post event_resources_path(event), params: params
      assert_response :success
      event.reload
      assert_equal expected, event.resource_ids.sort
    end
  end

  test 'admin user should add multiple resources' do
    event = events(:earthquake)
    adding = [
      resources(:shelter_four).id,
      resources(:shelter_five).id,
      resources(:pod_four).id,
      resources(:pod_five).id,
      resources(:medsite_two).id
    ].freeze
    expected = [*event.resource_ids.dup, *adding].sort.freeze
    params = { event: { resource_ids: adding } }

    sign_in users(:admin)
    assert_difference('ResourceActivation.count', adding.length) do
      post event_resources_path(event), params: params
      assert_response :success
      event.reload
      assert_equal expected, event.resource_ids.sort
    end
  end

  test 'posting deactivated resources should reactivate them' do
    event = events(:earthquake)
    expected = event.active_resources.map(&:id).sort.freeze
    params = { event: { resource_ids: expected } }

    sign_in users(:generic_one)
    assert_difference('ResourceActivation.count', 0) do
      post event_resources_path(event), params: params
      assert_response :success
      event.reload
      assert_equal expected, event.active_resources.map(&:id).sort
    end
  end

  #
  # toggling already associated resources: deactivate
  #

  # TODO: Security tests to ensure unauthorized users cannot mutate
  #       resource_activation active status

  test 'event administrator can deactivate individual resources' do
    event = events(:earthquake)
    params = {
      activations: {
        '0' => { # HACK: this '0' represents how the data gets serialized
          id: event.resource_activation(resources(:shelter_one)).id,
          active: false
        }
      }
    }

    sign_in users(:generic_one)
    assert_difference(->{ event.active_resources.count }, -1) do
      patch event_resources_path(event), params: params
      assert_response :success
    end
  end

  test 'event administrator can reactivate individual resources' do
    event = events(:earthquake)
    params = {
      activations: {
        '0' => { # HACK: this '0' represents how the data gets serialized
          id: event.resource_activation(resources(:shelter_three)).id,
          active: true
        }
      }
    }

    sign_in users(:generic_one)
    assert_difference(->{ event.active_resources.count }, 1) do
      patch event_resources_path(event), params: params
      assert_response :success
    end
  end

  #
  # Destroy deactivates all resources
  #

  test 'event administrator can disable all resources in one go' do
    event = events(:earthquake)
    assert_operator event.active_resources.count, :>, 0

    sign_in users(:generic_one)
    assert_difference ->{ event.resources.count }, 0 do
      delete event_resources_path(event)
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal event.active_resources.count, 0
    end
  end
end
