require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacheruser_#{SecureRandom.hex(4)}",
      role: "teacher"
    )

    @family = User.create!(
      email: "family-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "familyuser_#{SecureRandom.hex(4)}",
      role: "family"
    )

    @classroom = Classroom.create!(name: "Class A", teacher: @teacher)
  end

  # ---- DASHBOARD VIEWS ------------------------------------------------------

  test "requires sign in for teacher dashboard" do
    get teacher_dashboard_url
    assert_redirected_to new_user_session_path
  end

  test "requires sign in for family dashboard" do
    get family_dashboard_url
    assert_redirected_to new_user_session_path
  end

  test "teacher can view teacher dashboard" do
    sign_in @teacher
    get teacher_dashboard_url
    assert_response :success
  end

  test "family is redirected away from teacher dashboard" do
    sign_in @family
    get teacher_dashboard_url
    assert_redirected_to root_path
  end

  test "family can view family dashboard" do
    sign_in @family
    get family_dashboard_url
    assert_response :success
  end

  test "teacher is redirected away from family dashboard" do
    sign_in @teacher
    get family_dashboard_url
    assert_redirected_to root_path
  end

  # ---- CREATE CLASSROOM -----------------------------------------------------

  test "teacher can create classroom successfully" do
    sign_in @teacher

    assert_difference("Classroom.count", +1) do
      post create_classroom_url, params: { classroom: { name: "New Class" } }
    end

    assert_redirected_to teacher_dashboard_path
    assert_equal "Classroom created successfully.", flash[:notice]

    created = Classroom.order(:id).last
    assert_equal @teacher.id, created.teacher_id
    assert_equal "New Class", created.name
  end

  test "family cannot create classroom (redirects, no create)" do
    sign_in @family

    assert_no_difference("Classroom.count") do
      post create_classroom_url, params: { classroom: { name: "Nope" } }
    end

    assert_redirected_to root_path
  end

  # ---- CREATE CHILD ---------------------------------------------------------

  test "family can create child successfully (blank email auto-generated)" do
    sign_in @family

    assert_difference("User.count", +1) do
      post create_child_url, params: {
        user: {
          email: "",
          username: "child_#{SecureRandom.hex(3)}",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_redirected_to family_dashboard_path
    assert_equal "Child created successfully.", flash[:notice]

    child = User.order(:id).last
    assert_equal "student", child.role
    assert_equal @family.id, child.parent_id
    assert child.created_by_family, "expected created_by_family to be true"
    assert child.email.present?, "expected auto-generated email"
    assert_match(/@child\.local\z/, child.email)
  end

  test "family create_child renders family with 422 when invalid" do
    sign_in @family

    assert_no_difference("User.count") do
      post create_child_url, params: {
        user: {
          email: "",
          username: "", # invalid (username required)
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "teacher cannot create child (redirects, no create)" do
    sign_in @teacher

    assert_no_difference("User.count") do
      post create_child_url, params: {
        user: {
          email: "",
          username: "child_#{SecureRandom.hex(3)}",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_redirected_to root_path
  end

  # ---- CREATE STUDENT -------------------------------------------------------

  test "teacher can create student successfully (joins classroom)" do
    sign_in @teacher

    assert_difference("User.count", +1) do
      post create_student_url, params: {
        classroom_id: @classroom.id,
        user: {
          email: "student-#{SecureRandom.hex(4)}@example.com",
          username: "student_#{SecureRandom.hex(4)}",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_redirected_to teacher_dashboard_path
    assert_equal "Student added successfully.", flash[:notice]

    student = User.order(:id).last
    assert_equal "student", student.role
    assert_equal false, student.created_by_family
    assert_equal @classroom.id, student.classroom_id
  end

  test "teacher create_student renders teacher with 422 when invalid" do
    sign_in @teacher

    assert_no_difference("User.count") do
      post create_student_url, params: {
        classroom_id: @classroom.id,
        user: {
          email: "",     # allowed for students, but username is required
          username: "",  # invalid
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "family cannot create student (redirects, no create)" do
    sign_in @family

    assert_no_difference("User.count") do
      post create_student_url, params: {
        classroom_id: @classroom.id,
        user: {
          email: "student-#{SecureRandom.hex(4)}@example.com",
          username: "student_#{SecureRandom.hex(4)}",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_redirected_to root_path
  end

  test "teacher cannot create student into someone else's classroom (404)" do
    other_teacher = User.create!(
      email: "teacher2-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher2_#{SecureRandom.hex(4)}",
      role: "teacher"
    )
    other_classroom = Classroom.create!(name: "Other", teacher: other_teacher)

    sign_in @teacher

    assert_no_difference("User.count") do
      post create_student_url, params: {
        classroom_id: other_classroom.id,
        user: {
          email: "student-#{SecureRandom.hex(4)}@example.com",
          username: "student_#{SecureRandom.hex(4)}",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_response :not_found
  end
end
