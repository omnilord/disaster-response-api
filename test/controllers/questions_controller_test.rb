require 'test_helper'

class QuestionsControllerTest < DevisedTest
  setup do
    @question = questions(:question_one)
  end

  test 'should get index' do
    # anonymous user
    get questions_url
    assert_response :success

    #specified users
    %i[generic_one trusted admin].each do |u|
      user = users(u)
      sign_in user
      get questions_url
      assert_response :success, "#{u} user failed to view index."
      sign_out user
    end
  end

  test 'should show question' do
    # anonymous user
    get question_url(@question)
    assert_response :success

    # specified users
    %i[generic_one trusted admin].each do |u|
      user = users(u)
      sign_in user
      get question_url(@question)
      assert_response :success, "#{u} user failed to view question."
      sign_out user
    end
  end

  test 'anonymous user should not get new' do
    get new_question_url
    assert_response :redirect
    assert_redirected_to root_url
  end

  test 'known users should get new' do
    %i[generic_one trusted admin].each do |u|
      user = users(u)
      sign_in user
      get new_question_url
      assert_response :success, "#{u} user failed to view new question form."
    end
  end

  test 'anonymous user should not create draft or question' do
    assert_difference('Draft.count', 0) do
      assert_difference('Question.count', 0) do
        post questions_url, params: { question: { content: @question.content, active: @question.active } }
      end
    end
    assert_response :redirect
    assert_redirected_to root_url
  end

  test 'generic user should create draft of question' do
    sign_in users(:generic_one)
    assert_difference('Draft.count', 1) do
      assert_difference('Question.count', 0) do
        post questions_url, params: { question: { content: @question.content, active: @question.active } }
      end
    end
    assert_response :redirect
    assert_redirected_to draft_url(Draft.last)
  end

  test 'trusted user should create question' do
    sign_in users(:trusted)
    assert_difference('Draft.count', 1) do
      assert_difference('Question.count', 1) do
        post questions_url, params: { question: { content: @question.content, active: @question.active } }
      end
    end
    assert_response :redirect
    assert_redirected_to question_url(Question.last)
  end

  test 'admin user should create question' do
    sign_in users(:admin)
    assert_difference('Draft.count', 1) do
      assert_difference('Question.count', 1) do
        post questions_url, params: { question: { content: @question.content, active: @question.active } }
      end
    end
    assert_response :redirect
    assert_redirected_to question_url(Question.last)
  end

  test 'anonymous users should not get edit' do
    get edit_question_url(@question)
    assert_response :redirect
    assert_redirected_to root_url
  end

  test 'known users should get edit' do
    %i[generic_one trusted admin].each do |u|
      user = users(u)
      sign_in user
      get edit_question_url(@question)
      assert_response :success, "#{u} user failed to view edit question form."
    end
  end

  test 'anonymous users should not process updates' do
    assert_difference('Draft.count', 0) do
      assert_difference('Question.count', 0) do
        assert_no_changes('@question.attributes') do
          patch question_url(@question), params: { question: { content: 'This is the real question?', active: @question.active } }
        end
      end
    end
    assert_response :redirect
    assert_redirected_to root_url
  end

  test 'generic user should create draft update of question' do
    sign_in users(:generic_one)
    assert_difference('Draft.count', 1) do
      assert_difference('Question.count', 0) do
        assert_no_changes('@question.attributes') do
          patch question_url(@question), params: { question: { content: 'This is the real question?', active: @question.active } }
        end
      end
    end
    assert_response :redirect
    assert_redirected_to draft_url(Draft.last)
  end

  test 'trusted user should create draft and update question' do
    params = { question: { content: 'This is the real question?', active: @question.active } }
    comp = lambda do
      {
        content: @question.content,
        active: @question.active
      }
    end

    sign_in users(:trusted)
    assert_difference('Draft.count', 1) do
      assert_difference('Question.count', 0) do
        assert_changes(comp,
                       from: comp.call,
                       to: params[:question]) do
          patch question_url(@question), params: params
          @question.reload
        end
      end
    end
    assert_response :redirect
    assert_redirected_to question_url(@question)
  end

  test 'admin user should create draft and update question' do
    params = { question: { content: 'This is the real question?', active: @question.active } }
    comp = lambda do
      {
        content: @question.content,
        active: @question.active
      }
    end

    sign_in users(:admin)
    assert_difference('Draft.count', 1) do
      assert_difference('Question.count', 0) do
        assert_changes(comp,
                       from: comp.call,
                       to: params[:question]) do
          patch question_url(@question), params: params
          @question.reload
        end
      end
    end
    assert_response :redirect
    assert_redirected_to question_url(@question)
  end

  test 'anonymous user should not destroy question' do
    assert_difference('Question.count', 0) do
      assert_difference('Draft.count', 0) do
        delete question_url(@question)
      end
    end
    assert_response :redirect
    assert_redirected_to root_url
  end

  test 'generic user should not destroy question' do
    sign_in users(:generic_one)
    assert_difference('Question.count', 0) do
      assert_difference('Draft.count', 0) do
        delete question_url(@question)
      end
    end
    assert_response :redirect
    assert_redirected_to root_url
  end

  test 'trusted user should destroy question' do
    sign_in users(:trusted)
    assert_difference('Question.count', -1) do
      delete question_url(@question)
    end
    assert_response :redirect
    assert_redirected_to questions_url
  end

  test 'admin user should destroy question' do
    sign_in users(:admin)
    assert_difference('Question.count', -1) do
      delete question_url(@question)
    end
    assert_response :redirect
    assert_redirected_to questions_url
  end
end
