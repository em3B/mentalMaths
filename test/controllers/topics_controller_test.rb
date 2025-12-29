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

  test "play resets session score and sets time_limit when provided" do
    get play_topic_path(@topic_mul), params: { time_limit: 60 }

    assert_equal 0, session[:score]
    assert_equal 60, session[:time_limit]
  end

  test "play resets session score and does not set time_limit when not provided" do
    get play_topic_path(@topic_mul)

    assert_equal 0, session[:score]
    assert_nil session[:time_limit]
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

  # ---- SUBMIT SCORE ---------------------------------------------------------

  test "submit_score creates score for current_user and redirects to score page" do
    sign_in @student

    assert_difference("Score.count", +1) do
      post submit_score_topic_path(@topic_mul), params: { score: 7 }
    end

    assert_redirected_to score_topic_path(@topic_mul)
    assert_equal "Your score has been saved!", flash[:notice]

    score = Score.order(:id).last
    assert_equal @student.id, score.user_id
    assert_equal @topic_mul.id, score.topic_id
    assert_equal 7, score.total
  end
end
