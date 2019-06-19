require 'test_helper'
require 'minitest/spec'

class EventsManagersControllerTest < DevisedTest
  extend Minitest::Spec::DSL

  #
  # Edit view
  #

  test 'anonymous user should not get event managers index' do
    get event_managers_path(events(:earthquake))
    assert_response :redirect
    assert_redirected_to event_path(events(:earthquake))
  end

  test 'generic user should not get event managers index' do
    sign_in users(:generic_two)
    get event_managers_path(events(:earthquake))
    assert_response :redirect
    assert_redirected_to event_path(events(:earthquake))
  end

  test 'trusted user should not get event managers index' do
    sign_in users(:trusted)
    get event_managers_path(events(:earthquake))
    assert_response :redirect
    assert_redirected_to event_path(events(:earthquake))
  end

  test 'event manager should not get event managers index' do
    sign_in users(:generic_two)
    get event_managers_path(events(:earthquake))
    assert_response :redirect
    assert_redirected_to event_path(events(:earthquake))
  end

  test 'event administrator should get event managers index' do
    sign_in users(:generic_one)
    get event_managers_path(events(:earthquake))
    assert_response :success
  end

  test 'admin user should get event managers index' do
    sign_in users(:admin)
    get event_managers_path(events(:earthquake))
    assert_response :success
  end

  #
  # Add Managers
  #

  test 'anonymous user should not change event managers index' do
    event = events(:earthquake)
    expected = [ users(:generic_two).id, users(:generic_five).id ].sort.freeze
    params = { event: { manager_ids: expected } }

    assert_difference('EventManager.count', 0) do
      patch event_managers_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal [users(:generic_two).id], event.manager_ids.sort
    end
  end

  test 'generic user should not change event managers index' do
    event = events(:earthquake)
    expected = [ users(:generic_two).id, users(:generic_five).id ].sort.freeze
    params = { event: { manager_ids: expected } }

    sign_in users(:generic_three)
    assert_difference('EventManager.count', 0) do
      patch event_managers_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal [users(:generic_two).id], event.manager_ids.sort
    end
  end

  test 'trusted user should not change event managers index' do
    event = events(:earthquake)
    expected = [ users(:generic_two).id, users(:generic_five).id ].sort.freeze
    params = { event: { manager_ids: expected } }

    sign_in users(:trusted)
    assert_difference('EventManager.count', 0) do
      patch event_managers_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal [users(:generic_two).id], event.manager_ids.sort
    end
  end

  test 'event administrator should add one manager' do
    event = events(:earthquake)
    expected = [ users(:generic_two).id, users(:generic_five).id ].sort.freeze
    params = { event: { manager_ids: expected } }

    sign_in users(:generic_one)
    assert_difference('EventManager.count', 1) do
      patch event_managers_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal expected, event.manager_ids.sort
    end
  end

  test 'event administrator should add multiple managers' do
    event = events(:earthquake)
    expected = [
      users(:generic_two).id,
      users(:generic_five).id,
      users(:generic_six).id,
      users(:generic_seven).id,
      users(:generic_eight).id
    ].sort.freeze
    params = { event: { manager_ids: expected } }

    sign_in users(:generic_one)
    assert_difference('EventManager.count', 4) do
      patch event_managers_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal expected, event.manager_ids.sort
    end
  end

  test 'admin user should add multiple managers' do
    event = events(:earthquake)
    expected = [
      users(:generic_two).id,
      users(:generic_five).id,
      users(:generic_six).id,
      users(:generic_seven).id,
      users(:generic_eight).id
    ].sort.freeze
    params = { event: { manager_ids: expected } }

    sign_in users(:admin)
    assert_difference('EventManager.count', 4) do
      patch event_managers_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal expected, event.manager_ids.sort
    end
  end

  #
  # Remove Managers
  #

  test 'should removing managers' do
    event = events(:earthquake)
    event.manager_ids = [
      users(:generic_two).id,
      users(:generic_five).id,
      users(:generic_six).id,
      users(:generic_seven).id,
      users(:generic_eight).id
    ]
    assert_equal 5, event.managers.count

    expected = [
      users(:generic_six).id,
      users(:generic_seven).id,
      users(:generic_eight).id
    ].sort.freeze

    params = { event: { manager_ids: expected } }

    sign_in users(:generic_one)
    assert_difference('EventManager.count', -2) do
      patch event_managers_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal expected, event.manager_ids.sort
    end
  end


  # from here down:
  #   skipping tests against disallowed since those are controllerwide
  #   before_action macros against all actions.

  #
  # Change Administrator
  #

  test 'event administrator can hand off administration to another user' do
    event = events(:earthquake)

    params = { event: { administrator_id: users(:generic_four).id } }

    sign_in users(:generic_one)
    assert_difference('EventManager.count', 0) do
      patch event_managers_path(event), params: params
      assert_response :redirect
      assert_redirected_to event_path(event)
      event.reload
      assert_equal users(:generic_four).id, event.administrator.id
    end
  end

  #
  # Destroy removes all manages
  #

  test 'event administrator can delete all managers in one go' do
    event = events(:earthquake)

    sign_in users(:generic_one)
    delete event_managers_path(event)
    assert_response :redirect
    assert_redirected_to event_path(event)
    event.reload
    assert_equal 0, event.managers.count
  end
end
