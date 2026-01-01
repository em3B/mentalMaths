require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  TEST_PASSWORD = "correct-horse-battery-staple-42"

  setup do
    @teacher = confirm_for_devise!(User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher"
    ))

    @topic_open   = Topic.create!(title: "Open Topic",   category: "Multiplication", requires_auth: false)
    @topic_locked = Topic.create!(title: "Locked Topic", category: "Multiplication", requires_auth: true)

    @q1       = @topic_open.questions.create!(question_text: "2+2", correct_answer: 4)
    @q2       = @topic_open.questions.create!(question_text: "3+3", correct_answer: 6)
    @locked_q = @topic_locked.questions.create!(question_text: "5+5", correct_answer: 10)
  end

  def confirm_for_devise!(user)
    user.update!(confirmed_at: Time.current) if user.class.column_names.include?("confirmed_at")
    user.update!(locked_at: nil)            if user.class.column_names.include?("locked_at")
    user
  end

  # ---- SHOW -----------------------------------------------------------------

  test "show allows guest when topic does not require auth (not redirected)" do
    get topic_question_url(@topic_open, @q1)

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

  # ---- ANSWER (OPTION 1) ----------------------------------------------------
  # Option 1 behaviour:
  # - Do not create Response records
  # - Do not mutate session[:score]
  # - Return JSON telling the client whether the answer is correct

  test "answer as guest does not create Response and returns correct: true on correct answer" do
    assert_no_difference("Response.count") do
      post answer_topic_question_url(@topic_open, @q1), params: { value: @q1.correct_answer }
    end

    assert_response :success
    assert_nil session[:score]

    json = JSON.parse(response.body)
    assert_equal true, json["correct"]
  end

  test "answer as guest does not create Response and returns correct: false on incorrect answer" do
    assert_no_difference("Response.count") do
      post answer_topic_question_url(@topic_open, @q1), params: { value: @q1.correct_answer + 123 }
    end

    assert_response :success
    assert_nil session[:score]

    json = JSON.parse(response.body)
    assert_equal false, json["correct"]
  end

  test "answer as signed-in user does not create Response and returns correct: true on correct answer" do
    sign_in @teacher

    assert_no_difference("Response.count") do
      post answer_topic_question_url(@topic_open, @q1), params: { value: @q1.correct_answer }
    end

    assert_response :success
    assert_nil session[:score]

    json = JSON.parse(response.body)
    assert_equal true, json["correct"]
  end

  test "answer as signed-in user does not create Response and returns correct: false on incorrect answer" do
    sign_in @teacher

    wrong = @q1.correct_answer + 999

    assert_no_difference("Response.count") do
      post answer_topic_question_url(@topic_open, @q1), params: { value: wrong }
    end

    assert_response :success
    assert_nil session[:score]

    json = JSON.parse(response.body)
    assert_equal false, json["correct"]
  end

  test "answer redirects guest to sign in when topic requires auth" do
    post answer_topic_question_url(@topic_locked, @locked_q), params: { value: @locked_q.correct_answer }
    assert_redirected_to new_user_session_path
    assert_equal "Please sign in to access this topic.", flash[:alert]
  end
end
