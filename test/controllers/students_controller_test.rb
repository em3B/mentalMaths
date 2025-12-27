require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher"
    )

    @other_teacher = User.create!(
      email: "teacher2-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher2_#{SecureRandom.hex(4)}",
      role: "teacher"
    )

    @classroom = Classroom.create!(name: "Class #{SecureRandom.hex(3)}", teacher: @teacher)
    @other_classroom = Classroom.create!(name: "Other #{SecureRandom.hex(3)}", teacher: @other_teacher)

    @student = User.create!(
      email: "student-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "student_#{SecureRandom.hex(4)}",
      role: "student",
      classroom: @classroom
    )
  end

  # ---- AUTH -----------------------------------------------------------------

  test "index requires authentication" do
    get classroom_students_path(@classroom)
    assert_redirected_to new_user_session_path
  end

  test "new requires authentication" do
    get new_classroom_student_path(@classroom)
    assert_redirected_to new_user_session_path
  end

  test "create requires authentication" do
    post classroom_students_path(@classroom), params: { user: { username: "x", email: "x@example.com" } }
    assert_redirected_to new_user_session_path
  end

  test "destroy requires authentication" do
    delete classroom_student_path(@classroom, @student)
    assert_redirected_to new_user_session_path
  end

  # ---- AUTHZ (set_classroom uses current_user.classrooms.find -> 404) --------

  test "index returns 404 when classroom does not belong to current user" do
    sign_in @teacher
    get classroom_students_path(@other_classroom)
    assert_response :not_found
  end

  test "new returns 404 when classroom does not belong to current user" do
    sign_in @teacher
    get new_classroom_student_path(@other_classroom)
    assert_response :not_found
  end

  test "create returns 404 when classroom does not belong to current user" do
    sign_in @teacher
    post classroom_students_path(@other_classroom), params: { user: { username: "x", email: "x@example.com" } }
    assert_response :not_found
  end

  # ---- INDEX / NEW ----------------------------------------------------------

  test "teacher can view students index for their classroom (not redirected)" do
    sign_in @teacher
    get classroom_students_path(@classroom)

    assert_not_equal 302, response.status
    assert_not_equal new_user_session_path, response.location
  end

  test "teacher can view new student page for their classroom (not redirected)" do
    sign_in @teacher
    get new_classroom_student_path(@classroom)

    assert_not_equal 302, response.status
    assert_not_equal new_user_session_path, response.location
  end

  # ---- CREATE ---------------------------------------------------------------

  test "create creates a student, assigns role student, assigns classroom, and renders show_password (html)" do
    sign_in @teacher

    assert_difference("User.count", +1) do
      post classroom_students_path(@classroom),
           params: { user: { username: "new_student_#{SecureRandom.hex(3)}", email: "ns-#{SecureRandom.hex(3)}@example.com" } },
           headers: { "ACCEPT" => "text/html" }
    end

    assert_response :success

    created = User.order(:id).last
    assert_equal "student", created.role
    assert_equal @classroom.id, created.classroom_id
    assert created.encrypted_password.present?, "expected generated password to be set"
  end

  test "create renders classrooms/show with 422 when invalid" do
    sign_in @teacher

    # Most apps validate username presence; ensure invalid by omitting username
    assert_no_difference("User.count") do
      post classroom_students_path(@classroom),
           params: { user: { username: "", email: "bad@example.com" } },
           headers: { "ACCEPT" => "text/html" }
    end

    assert_response :unprocessable_entity
  end

  # ---- DESTROY --------------------------------------------------------------

  test "destroy removes student from classroom and redirects in html" do
    sign_in @teacher

    delete classroom_student_path(@classroom, @student), headers: { "ACCEPT" => "text/html" }

    assert_redirected_to classroom_path(@classroom)
    assert_equal "Student removed.", flash[:notice]

    @student.reload
    assert_nil @student.classroom_id
  end

  test "destroy returns 404 when student is not in the given classroom" do
    other_student = User.create!(
      email: "student2-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "student2_#{SecureRandom.hex(4)}",
      role: "student",
      classroom: @other_classroom
    )

    sign_in @teacher

    delete classroom_student_path(@classroom, other_student), headers: { "ACCEPT" => "text/html" }
    assert_response :not_found
  end

  test "destroy returns 404 when classroom does not belong to current user" do
    sign_in @teacher

    delete classroom_student_path(@other_classroom, @student), headers: { "ACCEPT" => "text/html" }
    assert_response :not_found
  end
end
