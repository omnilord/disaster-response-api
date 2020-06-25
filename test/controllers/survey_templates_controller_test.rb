require 'test_helper'

class SurveyTemplatesControllerTest < DevisedTest
  TRUSTED_USERS = %i[trusted admin].freeze

  setup do
    @survey_template = survey_templates(:survey_template_one)
  end

  test 'anonymous users should not have access' do
    # get index
    get survey_templates_url
    assert_response :redirect
    assert_redirected_to root_path

    # get show
    get survey_template_url(@survey_template)
    assert_response :redirect
    assert_redirected_to root_path

    # get new
    get new_survey_template_url
    assert_response :redirect
    assert_redirected_to root_path

    # post create
    assert_no_difference('SurveyTemplate.count') do
      assert_no_difference('Draft.count') do
        post survey_templates_url, params: {
          survey_template: {
            notes: @survey_template.notes,
            resource_type: @survey_template.resource_type,
          }
        }
      end
    end
    assert_response :redirect
    assert_redirected_to root_path

    # get edit
    get edit_survey_template_url(@survey_template)
    assert_response :redirect
    assert_redirected_to root_path

    # patch update
    assert_no_difference('SurveyTemplate.count') do
      assert_no_difference('Draft.count') do
        post survey_templates_url, params: {
          survey_template: {
            notes: @survey_template.notes,
            resource_type: @survey_template.resource_type,
          }
        }
      end
    end
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'untrusted users should not have access' do
    sign_in users(:generic_one)

    # get index
    get survey_templates_url
    assert_response :redirect
    assert_redirected_to root_path

    # get show
    get survey_template_url(@survey_template)
    assert_response :redirect
    assert_redirected_to root_path

    # get new
    get new_survey_template_url
    assert_response :redirect
    assert_redirected_to root_path

    # post create
    assert_no_difference('SurveyTemplate.count') do
      assert_no_difference('Draft.count') do
        post survey_templates_url, params: {
          survey_template: {
            notes: @survey_template.notes,
            resource_type: @survey_template.resource_type,
          }
        }
      end
    end
    assert_response :redirect
    assert_redirected_to root_path

    # get edit
    get edit_survey_template_url(@survey_template)
    assert_response :redirect
    assert_redirected_to root_path

    # patch update
    assert_no_difference('SurveyTemplate.count') do
      assert_no_difference('Draft.count') do
        post survey_templates_url, params: {
          survey_template: {
            notes: @survey_template.notes,
            resource_type: @survey_template.resource_type,
          }
        }
      end
    end
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'trusted users should get index' do
    # specified users
    TRUSTED_USERS.each do |u|
      user = users(u)
      sign_in user
      get survey_templates_url
      assert_response :success, "#{u} user failed to view index."
      sign_out user
    end
  end

  test "should show survey_template for trusted users" do
    # specific users
    TRUSTED_USERS.each do |u|
      user = users(u)
      sign_in user
      get survey_template_url(@survey_template)
      assert_response :success, "#{u} user failed to view survey template."
      sign_out user
    end
  end

  test 'trusted users should get new' do
    # specified users
    TRUSTED_USERS.each do |u|
      user = users(u)
      sign_in user
      get new_survey_template_url
      assert_response :success, "#{u} user failed to view new."
      sign_out user
    end
  end

  test "trusted users should create survey_template" do
    # specified users
    types = {
      admin: 'pod',
      trusted: 'medsite'
    }
    TRUSTED_USERS.each do |u|
      user = users(u)
      sign_in user
      assert_difference('SurveyTemplate.count', 1, "#{u} user failed to create survey template.") do
        assert_difference('Draft.count', 1, "#{u} user failed to create survey template draft for create.") do
          post survey_templates_url, params: {
            survey_template: {
              notes: 'Notes?  Notes.',
              resource_type: types[u],
              survey_template_questions_attributes: {
                '0' => { # This is correct
                  id: '',
                  active: '1',
                  private: '1',
                  position: '1',
                  required: '0',
                  question_id: questions(:question_one).id
                }
              }
            }
          }
          assert_redirected_to survey_template_url(SurveyTemplate.last)
        end
      end
      sign_out user
    end

    assert_redirected_to survey_template_url(SurveyTemplate.last)
  end

  test 'trusted users should get edit' do
    # specified users
    TRUSTED_USERS.each do |u|
      user = users(u)
      sign_in user
      get edit_survey_template_url(@survey_template)
      assert_response :success, "#{u} user failed to view edit."
      sign_out user
    end
  end

  test "trusted users should update survey_template" do
    sign_in users(:trusted)
    assert_no_difference('SurveyTemplate.count', 'trusted use created survey template instead of editing.') do
      assert_difference('Draft.count', 1, 'trusted user failed to create survey template draft for update.') do
        patch survey_template_url(@survey_template), params: {
          survey_template: {
            notes: 'Notes?  Notes.',
            survey_template_questions_attributes: {
              '0' => { # This is correct
                id: survey_template_questions(:stq_one).id,
                active: '1',
                private: '1',
                position: '1',
                required: '0',
                question_id: questions(:question_one).id
              },
              '1' => { # again, correct
                id: survey_template_questions(:stq_two).id,
                active: '1',
                private: '1',
                position: '2',
                required: '0',
                question_id: questions(:question_two).id
              },
              '2' => { # again, correct
                id: '',
                active: '1',
                private: '1',
                position: '3',
                required: '0',
                question_id: questions(:question_three).id
              },
              '3' => { # again, correct
                id: '',
                active: '1',
                private: '1',
                position: '4',
                required: '0',
                question_id: questions(:question_four).id
              }
            }
          }
        }
        assert_redirected_to survey_template_url(@survey_template)
      end
    end
  end

  test "admin users should update survey_template" do
    sign_in users(:admin)
    assert_no_difference('SurveyTemplate.count', 'admin use created survey template instead of editing.') do
      assert_difference('Draft.count', 1, 'admin user failed to create survey template draft for update.') do
        patch survey_template_url(@survey_template), params: {
          survey_template: {
            notes: 'Notes?  Notes.',
            survey_template_questions_attributes: {
              '0' => { # This is correct
                id: survey_template_questions(:stq_one).id,
                active: '1',
                private: '1',
                position: '1',
                required: '0',
                question_id: questions(:question_one).id
              },
              '1' => { # again, correct
                id: survey_template_questions(:stq_two).id,
                active: '1',
                private: '1',
                position: '2',
                required: '0',
                question_id: questions(:question_two).id
              },
              '2' => { # again, correct
                id: '',
                active: '1',
                private: '1',
                position: '3',
                required: '0',
                question_id: questions(:question_three).id
              },
              '3' => { # again, correct
                id: '',
                active: '1',
                private: '1',
                position: '4',
                required: '0',
                question_id: questions(:question_four).id
              }
            }
          }
        }
        assert_redirected_to survey_template_url(@survey_template)
      end
    end
  end
end
