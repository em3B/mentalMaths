require "test_helper"

class ClassroomsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher"
    )

    @family = User.create!(
      email: "family-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "family_#{SecureRandom.hex(4)}",
      role: "family"
    )

    @classroom = Classroom.create!(
      name: "Class A",
      teacher: @teacher
    )
  end

  def html_headers
    { "HTTP_ACCEPT" => "text/html" }
  end

  # ---- AUTH / ROLE GATE -----------------------------------------------------

  test "redirects to sign in when logged out" do
    get classrooms_url(format: :html), headers: html_headers
    assert_redirected_to new_user_session_path
  end

  test "redirects non-teacher to root" do
    sign_in @family

    get classrooms_url(format: :html), headers: html_headers
    assert_redirected_to root_path
  end

  # ---- INDEX ----------------------------------------------------------------

  test "teacher can view index" do
    sign_in @teacher

    get classrooms_url(format: :html), headers: html_headers
    assert_response :success
  end

  # ---- SHOW -----------------------------------------------------------------

  test "teacher can view their classroom" do
    sign_in @teacher

    get classroom_url(@classroom, format: :html), headers: html_headers
    assert_response :success
  end

  test "teacher cannot view someone else's classroom (404)" do
    other_teacher = User.create!(
      email: "teacher2-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher2_#{SecureRandom.hex(4)}",
      role: "teacher"
    )
    other_classroom = Classroom.create!(name: "Other Class", teacher: other_teacher)

    sign_in @teacher

    get classroom_url(other_classroom, format: :html), headers: html_headers
    assert_response :not_found
  end

  # ---- CREATE ---------------------------------------------------------------

  test "teacher can create classroom (from index form flow)" do
    sign_in @teacher

    assert_difference("Classroom.count", +1) do
      post classrooms_url(format: :html),
           params: { classroom: { name: "New Class" } },
           headers: html_headers
    end

    created = Classroom.order(:id).last
    assert_redirected_to classroom_url(created)
    assert_equal "Classroom created", flash[:notice]
    assert_equal @teacher.id, created.teacher_id
  end

  # ---- DESTROY --------------------------------------------------------------

  test "teacher can destroy their classroom" do
    sign_in @teacher

    assert_difference("Classroom.count", -1) do
      delete classroom_url(@classroom, format: :html), headers: html_headers
    end

    assert_redirected_to classrooms_url
    assert_equal "Classroom deleted", flash[:notice]
  end

  test "teacher cannot destroy someone else's classroom (404)" do
    other_teacher = User.create!(
      email: "teacher3-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher3_#{SecureRandom.hex(4)}",
      role: "teacher"
    )
    other_classroom = Classroom.create!(name: "Not Yours", teacher: other_teacher)

    sign_in @teacher

    assert_no_difference("Classroom.count") do
      delete classroom_url(other_classroom, format: :html), headers: html_headers
    end

    assert_response :not_found
  end
end
