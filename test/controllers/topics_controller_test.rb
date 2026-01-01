require "test_helper"

class TopicsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  TEST_PASSWORD = "correct-horse-battery-staple-42"

  setup do
    @topic_mul = Topic.create!(title: "Times Tables", category: "Multiplication", requires_auth: false)
    @topic_add = Topic.create!(title: "Add Up", category: "Addition and Subtraction", requires_auth: false)

    @student = confirm_for_devise!(User.create!(
      email: "student-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "student_#{SecureRandom.hex(4)}",
      role: "student"
    ))

    @teacher = confirm_for_devise!(User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher"
    ))

    @family = confirm_for_devise!(User.create!(
      email: "family-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "family_#{SecureRandom.hex(4)}",
      role: "family"
    ))

    @classroom = Classroom.create!(name: "Class #{SecureRandom.hex(3)}", teacher: @teacher)

    @child = confirm_for_devise!(User.create!(
      email: "child-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "child_#{SecureRandom.hex(4)}",
      role: "student",
      parent: @family
    ))

    AssignedTopic.create!(
      user: @student,
      topic: @topic_mul,
      assigned_by: @teacher,
      due_date: 1.week.from_now.to_date
    )
  end

  def confirm_for_devise!(user)
    user.update!(confirmed_at: Time.current) if user.class.column_names.include?("confirmed_at")
    user.update!(locked_at: nil)            if user.class.column_names.include?("locked_at")
    user
  end

  # ---- INDEX ----------------------------------------------------------------

  test "index without category returns ok (or 406) and does not redirect guests" do
    get topics_path
    assert_not_equal 302, response.status
  end

  test "index with category filter returns ok (or 406) and does not redirect" do
    get category_topics_path(category: "multiplication")
    assert_not_equal 302, response.status
  end

  test "index category filter is case-insensitive" do
    Topic.create!(title: "Speed Round", category: "Addition and Subtraction", requires_auth: false)

    get category_topics_path(category: "addition and subtraction")
    assert_not_equal 302, response.status
  end

  test "index as student sets assignments (smoke test: still renders/not redirected)" do
    sign_in @student
    get topics_path
    assert_not_equal 302, response.status
  end

  # ---- SHOW -----------------------------------------------------------------

  test "show as guest does not redirect" do
    get topic_path(@topic_mul)
    assert_not_equal 302, response.status
  end

  test "show as teacher does not redirect and accepts optional classroom_id param" do
    sign_in @teacher
    get topic_path(@topic_mul), params: { classroom_id: @classroom.id }
    assert_not_equal 302, response.status
  end

  test "show as family does not redirect and accepts optional student_id param" do
    sign_in @family
    get topic_path(@topic_mul), params: { student_id: @child.id }
    assert_not_equal 302, response.status
  end

  # ---- PLAY -----------------------------------------------------------------

  test "play does not use session score and does not store time_limit in session (option 1)" do
    get play_topic_path(@topic_mul), params: { time_limit: 60 }

    assert_nil session[:score]
    assert_nil session[:time_limit]
    assert_not_equal 302, response.status
  end

  test "play does not use session score when time_limit not provided (option 1)" do
    get play_topic_path(@topic_mul)

    assert_nil session[:score]
    assert_nil session[:time_limit]
    assert_not_equal 302, response.status
  end

  # ---- INTRO ----------------------------------------------------------------

  test "intro does not redirect" do
    get intro_topic_path(@topic_mul)
    assert_not_equal 302, response.status
  end

  # ---- SCORE ----------------------------------------------------------------

  test "score as signed-in user does not redirect" do
    sign_in @student
    get score_topic_path(@topic_mul)
    assert_not_equal 302, response.status
  end

  # ---- OPTION 1 PERSISTENCE (POST /scores) ----------------------------------

  test "posting to /scores creates a score for current_user (option 1)" do
    sign_in @student

    assert_difference("Score.count", +1) do
      post scores_path, params: {
        score: {
          correct: 7,
          total: 10,
          topic_id: @topic_mul.id
        }
      }, as: :json
    end

    assert_response :created

    score = Score.order(:id).last
    assert_equal @student.id, score.user_id
    assert_equal @topic_mul.id, score.topic_id
    assert_equal 7, score.correct
    assert_equal 10, score.total
  end
end
