require "application_system_test_case"

class TeacherAddsClassroomTest < ApplicationSystemTestCase
  TEST_PASSWORD = "correct-horse-battery-staple-42"

  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher"
    )

    # If you enabled Devise confirmable/lockable, make the test user sign-in ready.
    @teacher.update!(confirmed_at: Time.current) if @teacher.class.column_names.include?("confirmed_at")
    @teacher.update!(locked_at: nil)            if @teacher.class.column_names.include?("locked_at")
  end

  test "teacher can add a classroom from the teacher dashboard" do
    visit new_user_session_path

    # ---- Login ---------------------------------------------------------------
    select "Teacher", from: "Role"
    fill_in "Username or Email", with: @teacher.email
    find('input[name="user[password]"]').set(TEST_PASSWORD)
    click_button "Log in"

    assert_current_path teacher_dashboard_path
    assert_text "Add a Classroom"

    # ---- Create classroom ----------------------------------------------------
    classroom_name = "Classroom #{SecureRandom.hex(3)}"
    find('input[placeholder="Classroom Name"]').set(classroom_name)
    click_button "Add"

    assert_text "Classroom created successfully."

    # ---- Verify via classrooms index ----------------------------------------
    click_link "My Classrooms"
    assert_text classroom_name
  end
end
