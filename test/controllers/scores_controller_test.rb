require "test_helper"

class ScoresControllerTest < ActionDispatch::IntegrationTest
  TEST_PASSWORD = "correct-horse-battery-staple-42"

  setup do
    @topic = Topic.create!(
      title: "Addition",
      intro: "Intro",
      public: true,
      requires_auth: true,
      category: "Addition and Subtraction"
    )
  end

  def create_score_for(user, correct: 8, total: 10, created_at: 1.day.ago)
    Score.create!(
      user: user,
      topic: @topic,
      correct: correct,
      total: total,
      created_at: created_at,
      updated_at: created_at
    )
  end

  # Matches your custom Devise login form fields:
  # user[role], user[login], user[password]
  def sign_in_via_devise!(user, login_value: nil)
    user.update!(confirmed_at: Time.current) if user.respond_to?(:confirmed_at) && user.confirmed_at.nil?

    login_value ||= (user.username.presence || user.email)

    post user_session_path, params: {
      user: {
        role: user.role,
        login: login_value,
        password: TEST_PASSWORD
      }
    }

    follow_redirect! if response.redirect?

    assert_not_equal 422, response.status, "Login failed (422). Body:\n#{response.body}"
  end

  test "student index shows their own scores" do
    student = User.create!(
      email: "student@example.com",
      password: TEST_PASSWORD,
      username: "stud1",
      role: "student"
    )

    create_score_for(student, correct: 7, total: 10, created_at: 2.days.ago)
    create_score_for(student, correct: 10, total: 10, created_at: 1.day.ago)

    sign_in_via_devise!(student)

    get scores_path
    assert_response :success

    assert_includes response.body, "stud1"
    assert_includes response.body, "7 / 10"
    assert_includes response.body, "10 / 10"
  end

  test "student show ignores requested id and shows signed-in student's scores only" do
    student = User.create!(
      email: "s1@example.com",
      password: TEST_PASSWORD,
      username: "s1",
      role: "student"
    )
    other = User.create!(
      email: "s2@example.com",
      password: TEST_PASSWORD,
      username: "s2",
      role: "student"
    )

    create_score_for(student, correct: 9, total: 10)
    create_score_for(other, correct: 10, total: 10)

    sign_in_via_devise!(student)

    # IMPORTANT: scores#show route is /students/:id/scores
    # Even if student requests "other", controller should show current_user instead (per your Option 2 logic)
    get student_scores_path(other.id)
    assert_response :success
    assert_includes response.body, "<h1>s1</h1>"
    assert_includes response.body, "9 / 10"
    refute_includes response.body, "10 / 10"
  end

  test "family index shows selected child's scores when authorized" do
    family = User.create!(
      email: "family@example.com",
      password: TEST_PASSWORD,
      username: "fam1",
      role: "family"
    )

    child = User.create!(
      email: "child@example.com",
      password: TEST_PASSWORD,
      username: "kid1",
      role: "student",
      parent_id: family.id
    )

    create_score_for(child, correct: 6, total: 10)

    sign_in_via_devise!(family)

    get scores_path(child_id: child.id)
    assert_response :success

    assert_includes response.body, "kid1"
    assert_includes response.body, "6 / 10"
  end

  test "family show is blocked for non-child" do
    family = User.create!(
      email: "family2@example.com",
      password: TEST_PASSWORD,
      username: "fam2",
      role: "family"
    )

    not_their_child = User.create!(
      email: "kid2@example.com",
      password: TEST_PASSWORD,
      username: "kid2",
      role: "student"
    )

    create_score_for(not_their_child, correct: 10, total: 10)

    sign_in_via_devise!(family)

    get student_scores_path(not_their_child.id)
    assert_response :redirect
  end

  test "teacher index shows scores for a student in their classroom" do
    teacher = User.create!(
      email: "teacher@example.com",
      password: TEST_PASSWORD,
      username: "teach1",
      role: "teacher"
    )

    student = User.create!(
      email: "student3@example.com",
      password: TEST_PASSWORD,
      username: "stud3",
      role: "student"
    )

    other_student = User.create!(
      email: "student4@example.com",
      password: TEST_PASSWORD,
      username: "stud4",
      role: "student"
    )

    classroom = Classroom.create!(name: "Class A", teacher: teacher)
    Membership.create!(user: student, classroom: classroom)

    create_score_for(student, correct: 8, total: 10)
    create_score_for(other_student, correct: 10, total: 10)

    sign_in_via_devise!(teacher)

    get scores_path(student_id: student.id)
    assert_response :success

    assert_includes response.body, "stud3"
    assert_includes response.body, "8 / 10"
    refute_includes response.body, "stud4"
    refute_includes response.body, "10 / 10"
  end

  test "teacher index rejects student not in their classroom" do
    teacher = User.create!(
      email: "teacher2@example.com",
      password: TEST_PASSWORD,
      username: "teach2",
      role: "teacher"
    )

    other_student = User.create!(
      email: "student5@example.com",
      password: TEST_PASSWORD,
      username: "stud5",
      role: "student"
    )

    sign_in_via_devise!(teacher)

    get scores_path(student_id: other_student.id)
    assert_response :redirect
  end

  test "create score creates a score for current_user" do
    student = User.create!(
      email: "student_create@example.com",
      password: TEST_PASSWORD,
      username: "stud_create",
      role: "student"
    )

    sign_in_via_devise!(student)

    assert_difference -> { Score.count }, 1 do
      post scores_path, params: {
        score: { correct: 9, total: 10, topic_id: @topic.id }
      }, as: :json
    end

    assert_response :created

    score = Score.order(created_at: :desc).first
    assert_equal student.id, score.user_id
    assert_equal @topic.id, score.topic_id
    assert_equal 9, score.correct
    assert_equal 10, score.total
  end
end
