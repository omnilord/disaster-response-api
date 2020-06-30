require 'test_helper'
require 'minitest/spec'

class EventsControllerTest < DevisedTest
  extend Minitest::Spec::DSL

  let(:default_params) do
    {
      event: {
        name: 'A Fire. A wild wild fire.',
        disaster_type: 'wildfire',
        content: 'Another fire in California.',
        administrator_id: users(:admin).id,
        latitude: 46.192254,
        longitude: -122.195701,
        zoom: 9.0
      }
    }
  end

  #
  # anyone should be able to see events
  #

  test 'anonymous user should get event index' do
    get events_path
    assert_response :success
  end

  test 'generic user should get event index' do
    sign_in users(:generic_one)
    get events_path
    assert_response :success
  end

  test 'trusted user should get event index' do
    sign_in users(:trusted)
    get events_path
    assert_response :success
  end

  test 'admin user should get event index' do
    sign_in users(:admin)
    get events_path
    assert_response :success
  end

  test 'anonymous users can see individual events' do
    get event_path(events(:hurricane))
    assert_response :success
  end

  test 'generic users can see individual events' do
    sign_in users(:generic_one)
    get event_path(events(:hurricane))
    assert_response :success
  end

  test 'trusted users can see individual events' do
    sign_in users(:trusted)
    get event_path(events(:hurricane))
    assert_response :success
  end

  test 'admin users can see individual events' do
    sign_in users(:admin)
    get event_path(events(:hurricane))
    assert_response :success
  end

  #
  # only logged in users should be able to mutate events
  #

  test 'anonymous users should not get new' do
    get new_event_path
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'generic users can get new' do
    sign_in users(:generic_one)
    get new_event_path
    assert_response :success
  end

  test 'trusted users can get new' do
    sign_in users(:admin)
    get new_event_path
    assert_response :success
  end

  test 'admin users can get new' do
    sign_in users(:admin)
    get new_event_path
    assert_response :success
  end

  test 'anonymous users should not create event' do
    assert_difference('Draft.count', 0) do
      assert_difference('Event.count', 0) do
        post events_path, params: default_params
        assert_response :redirect
        assert_redirected_to root_path
      end
    end
  end

  test 'generic users should create a draft event' do
    sign_in users(:generic_one)
    assert_difference('Draft.count', 1) do
      assert_difference('Event.count', 0) do
        post events_path, params: default_params
        assert_response :redirect
        assert_redirected_to draft_path(Draft.last)
      end
    end
  end

  test 'trusted users should create a draft and event' do
    sign_in users(:trusted)
    assert_difference('Draft.count', 1) do
      assert_difference('Event.count', 1) do
        post events_path, params: default_params
        assert_response :redirect
        assert_redirected_to event_path(Event.last)
      end
    end
  end

  test 'admin users should create a draft and event' do
    sign_in users(:admin)
    assert_difference('Draft.count', 1) do
      assert_difference('Event.count', 1) do
        post events_path, params: default_params
        assert_response :redirect
        assert_redirected_to event_path(Event.last)
      end
    end
  end

  #
  # Users with admin access to the event can edit and save
  #   other users will create drafts
  #

  test 'anonymous users should not get edit' do
    get edit_event_path(events(:hurricane))
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'generic users can get edit' do
    sign_in users(:generic_one)
    get edit_event_path(events(:hurricane))
    assert_response :success
  end

  test 'trusted users can get edit' do
    sign_in users(:admin)
    get edit_event_path(events(:hurricane))
    assert_response :success
  end

  test 'admin users can get edit' do
    sign_in users(:admin)
    get edit_event_path(events(:hurricane))
    assert_response :success
  end

  test 'anonymous users should not update event' do
    params = default_params.dup
    params[:event].delete(:administrator_id)

    patch event_path(events(:hurricane)), params: params
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Generic users only create a draft when updating events' do
    event = events(:hurricane)
    params = default_params.dup
    params[:event].delete(:administrator_id)

    sign_in users(:generic_one)
    assert_difference('Draft.count', 1) do
      assert_difference('Event.count', 0) do
        assert_no_changes('event.attributes') do
          patch event_path(event), params: params
          assert_response :redirect
          event.reload
          assert_redirected_to draft_path(event.drafts.last)
        end
      end
    end
  end

  test 'trusted users create and apply a draft when updating events' do
    event = events(:hurricane)
    comp = lambda do
      {
        name: event.name,
        disaster_type: event.disaster_type,
        content: event.content,
        latitude: event.latitude,
        longitude: event.longitude,
        zoom: event.zoom
      }
    end
    params = default_params.dup
    params[:event].delete(:administrator_id)

    sign_in users(:trusted)
    assert_difference('Draft.count', 1) do
      assert_difference('Event.count', 0) do
        assert_changes(comp,
                       from: comp.call,
                       to: params[:event]) do
          patch event_path(event), params: params
          assert_response :redirect
          event.reload
          assert_equal users(:trusted), event.current_draft.user
          assert_redirected_to event_path(event)
        end
      end
    end
  end

  test 'admin users create and apply a draft when updating events' do
    event = events(:hurricane)
    comp = lambda do
      {
        name: event.name,
        disaster_type: event.disaster_type,
        content: event.content,
        latitude: event.latitude,
        longitude: event.longitude,
        zoom: event.zoom
      }
    end
    params = default_params.dup
    params[:event].delete(:administrator_id)

    sign_in users(:admin)
    assert_difference('Draft.count', 1) do
      assert_difference('Event.count', 0) do
        assert_changes(comp,
                       from: comp.call,
                       to: params[:event]) do
          patch event_path(event), params: params
          assert_response :redirect
          event.reload
          assert_equal users(:admin), event.current_draft.user
          assert_redirected_to event_path(event)
        end
      end
    end
  end

  test 'generic users as event administrators create and apply a draft when updating events' do
    event = events(:earthquake)
    comp = lambda do
      {
        name: event.name,
        disaster_type: event.disaster_type,
        content: event.content,
        latitude: event.latitude,
        longitude: event.longitude,
        zoom: event.zoom
      }
    end
    params = default_params.dup
    params[:event].delete(:administrator_id)

    sign_in users(:generic_one)
    assert_difference('Draft.count', 1) do
      assert_difference('Event.count', 0) do
        assert_changes(comp,
                       from: comp.call,
                       to: params[:event]) do
          patch event_path(event), params: params
          assert_response :redirect
          event.reload
          assert_equal users(:generic_one), event.current_draft.user
          assert_redirected_to event_path(event)
        end
      end
    end
  end

  test 'generic users as event managers create and apply a draft when updating events' do
    event = events(:earthquake)
    comp = lambda do
      {
        name: event.name,
        disaster_type: event.disaster_type,
        content: event.content,
        latitude: event.latitude,
        longitude: event.longitude,
        zoom: event.zoom
      }
    end
    params = default_params.dup
    params[:event].delete(:administrator_id)

    sign_in users(:generic_two)
    assert_difference('Draft.count', 1) do
      assert_difference('Event.count', 0) do
        assert_changes(comp,
                       from: comp.call,
                       to: params[:event]) do
          patch event_path(event), params: params
          assert_response :redirect
          event.reload
          assert_equal users(:generic_two), event.current_draft.user
          assert_redirected_to event_path(event)
        end
      end
    end
  end

  test 'updating map coordinates are saved' do
    skip
  end

=begin
  test 'should destroy event' do
    assert_difference('Event.count', -1) do
      delete event_path(events(:hurricane))
    end

    assert_redirected_to events_path
  end
=end
end
