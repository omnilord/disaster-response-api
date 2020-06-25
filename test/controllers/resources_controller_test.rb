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

  let(:shelter1) do
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
    get resource_path(shelter1)
    assert_response :success
  end

  test 'generic users can see individual resources' do
    sign_in users(:generic_one)
    get resource_path(shelter1)
    assert_response :success
  end

  test 'trusted users can see individual resources' do
    sign_in users(:trusted)
    get resource_path(shelter1)
    assert_response :success
  end

  test 'admin users can see individual resources' do
    sign_in users(:admin)
    get resource_path(shelter1)
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
    get edit_resource_path(shelter1)
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'generic users can get edit' do
    sign_in users(:generic_one)
    get edit_resource_path(shelter1)
    assert_response :success
  end

  test 'trusted users can get edit' do
    sign_in users(:trusted)
    get edit_resource_path(shelter1)
    assert_response :success
  end

  test 'admin users can get edit' do
    sign_in users(:admin)
    get edit_resource_path(shelter1)
    assert_response :success
  end

  test 'anonymous users should not update resource' do
    patch resource_path(shelter1), params: params
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'Generic users only create a draft when updating resources' do
    resource = shelter1
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
    resource = shelter1
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
    resource = shelter1
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

  describe 'ResourcesControllerTest with survey data' do
    let(:shelter2) do
      resources(:shelter_two)
    end

    let(:unanswered_list) do
      [
        answer_params(survey_template_questions(:stq_one), ''),
        answer_params(survey_template_questions(:stq_two), ''),
        answer_params(survey_template_questions(:stq_five), '')
      ]
    end

    let(:answered_list) do
      [
        answer_params(survey_template_questions(:stq_one), 'test1'),
        answer_params(survey_template_questions(:stq_two), 'test2'),
        answer_params(survey_template_questions(:stq_five), 'test5')
      ]
    end

    def answer_params(stq, content, id = nil, u_at = nil)
      [
        { survey_template_question_id: stq&.id },
        { content: content },
        { id: id },
        { updated_at: u_at }
      ]
    end

    def answering_params(resource, answers = [])
      {
        resource: {
          name: resource.name,
          resource_type: resource.resource_type,
          address: resource.address,
          city: resource.city,
          state: resource.state,
          postal_code: resource.postal_code,
          county: resource.county,
          answers_attributes: answers.flatten
        }
      }
    end

    test 'No answers are created if questions are not provided' do
      resource = shelter2

      sign_in users(:admin)
      assert_difference('Draft.count', 1) do
        assert_difference('Resource.count', 0) do
          assert_difference('Answer.count', 0) do
            patch resource_path(resource), params: params
            assert_response :redirect
            resource.reload
            assert_equal 0, resource.answers.count
          end
        end
      end
    end

    test 'Answers are created when saving' do
      resource = shelter2
      a_params = answering_params(resource, answered_list)

      sign_in users(:admin)
      assert_difference('Draft.count', 1) do
        assert_difference('Resource.count', 0) do
          assert_difference('Answer.count', 3) do
            patch resource_path(resource), params: a_params
            assert_response :redirect
            resource.reload
            assert_equal 3, resource.answers.count
          end
        end
      end
    end

    test 'Answers are not created when input is left blank' do
      resource = shelter2
      a_params = answering_params(resource, unanswered_list)

      sign_in users(:admin)
      assert_difference('Draft.count', 1) do
        assert_difference('Resource.count', 0) do
          assert_difference('Answer.count', 0) do
            patch resource_path(resource), params: a_params
            assert_response :redirect
            resource.reload
            assert_equal 0, resource.answers.count
          end
        end
      end
    end

    test 'Existing answers are not updated when not changed' do
      resource = shelter1
      old_answers = resource.answers.most_recent.map do |a|
        answer_params(a.survey_template_question, a.content, a.id, a.updated_at)
      end
      a_params = answering_params(resource, old_answers.map { |a| a.first(3) })
      a_params[:resource][:name] = 'changing a different field'
      comp = proc { resource.answers.map { |a| a.attributes } }

      sign_in users(:admin)
      assert_difference('Draft.count', 1) do
        assert_difference('Resource.count', 0) do
          assert_difference('Answer.count', 0) do
            assert_no_changes(comp) do
              patch resource_path(resource), params: a_params
              assert_response :redirect
              resource.reload
              assert_equal 4, resource.answers.most_recent.count

              answers = resource.answers.most_recent.map do |a|
                answer_params(a.survey_template_question, a.content, a.id, a.updated_at)
              end

              assert_equal old_answers, answers
            end
          end
        end
      end
    end

    test 'Existing answers are replaces with newer entries when changed' do
      resource = shelter1
      old_answer_ids = resource.answers.most_recent.map(&:id)
      a_params = answering_params(resource, resource.answers.most_recent.map do |a|
        stq = a.survey_template_question
        [
          { survey_template_question_id: stq.id },
          { content: "new value for #{stq.id}" }
        ]
      end)
      comp = proc { resource.answers.map { |a| a.attributes } }


      sign_in users(:admin)
      assert_difference('Draft.count', 1) do
        assert_difference('Resource.count', 0) do
          assert_difference('Answer.count', 4) do
            patch resource_path(resource), params: a_params
            assert_response :redirect
            resource.reload
            assert_equal 4, resource.answers.most_recent.count

            new_answer_ids = resource.answers.most_recent.map(&:id)
            assert_empty old_answer_ids & new_answer_ids
          end
        end
      end
    end

    test 'Saving ad-hoc question with answer...TODO' do
      # This feature will require modifying the before create
      # callback in Answer to save the question config without
      # a survey_template_question OR to create a new one.
      skip
    end

    test 'Deleting an answer...TODO' do
      # This is used to undo the last edit
      skip
    end

    test 'Deleting a question from the resource removes all answers from the resource...TODO' do
      # this is used to blank the question entirely in the template
      skip
    end
  end
end
