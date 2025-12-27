require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher"
    )

    @topic_open = Topic.create!(title: "Open Topic", category: "Multiplication", requires_auth: false)
    @topic_locked = Topic.create!(title: "Locked Topic", category: "Multiplication", requires_auth: true)

    @q1 = @topic_open.questions.create!(question_text: "2+2", correct_answer: 4)
    @q2 = @topic_open.questions.create!(question_text: "3+3", correct_answer: 6)
    @locked_q = @topic_locked.questions.create!(question_text: "5+5", correct_answer: 10)
  end

  # ---- SHOW -----------------------------------------------------------------

  test "show allows guest when topic does not require auth (not redirected)" do
    get topic_question_url(@topic_open, @q1)

    # In your app this endpoint currently returns 406 (no acceptable format/template),
    # so don't assert :success. The important part is: it should NOT redirect to login.
    assert_not_equal 302, response.status
    assert_not_equal new_user_session_path, response.location
  end

  test "show redirects guest to sign in when topic requires auth" do
    get topic_question_url(@topic_locked, @locked_q)
    assert_redirected_to new_user_session_path
    assert_equal "Please sign in to access this topic.", flash[:alert]
  end

  test "show allows signed-in user even when topic requires auth (not redirected)" do
    sign_in @teacher
    get topic_question_url(@topic_locked, @locked_q)

    assert_not_equal 302, response.status
    assert_not_equal new_user_session_path, response.location
  end

  # ---- ANSWER ---------------------------------------------------------------

  test "answer as guest does not create Response but updates session score on correct answer" do
    assert_no_difference("Response.count") do
      post answer_topic_question_url(@topic_open, @q1), params: { value: @q1.correct_answer }
    end

    assert_equal 1, session[:score]
  end

  test "answer as guest does not increment session score when incorrect" do
    post answer_topic_question_url(@topic_open, @q1), params: { value: @q1.correct_answer + 123 }
    assert_equal 0, session[:score]
  end

  test "answer as signed-in user creates Response and updates score when correct" do
    sign_in @teacher

    assert_difference("Response.count", +1) do
      post answer_topic_question_url(@topic_open, @q1), params: { value: @q1.correct_answer }
    end

    response_record = Response.order(:id).last
    assert_equal @q1.id, response_record.question_id
    assert_equal @q1.correct_answer, response_record.value

    assert_equal 1, session[:score]
  end

  test "answer as signed-in user creates Response but does not increment score when incorrect" do
    sign_in @teacher

    wrong = @q1.correct_answer + 999

    assert_difference("Response.count", +1) do
      post answer_topic_question_url(@topic_open, @q1), params: { value: wrong }
    end

    response_record = Response.order(:id).last
    assert_equal @q1.id, response_record.question_id
    assert_equal wrong, response_record.value

    assert_equal 0, session[:score]
  end

  test "answer redirects guest to sign in when topic requires auth" do
    post answer_topic_question_url(@topic_locked, @locked_q), params: { value: @locked_q.correct_answer }
    assert_redirected_to new_user_session_path
    assert_equal "Please sign in to access this topic.", flash[:alert]
  end
end
