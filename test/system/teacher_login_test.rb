require "application_system_test_case"

class TeacherLoginTest < ApplicationSystemTestCase
  TEST_PASSWORD = "correct-horse-battery-staple-42"

  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher"
    )

    # Ensure the user can actually sign in when confirmable / lockable are enabled
    @teacher.update!(confirmed_at: Time.current) if @teacher.class.column_names.include?("confirmed_at")
    @teacher.update!(locked_at: nil)            if @teacher.class.column_names.include?("locked_at")
  end

  test "teacher can log in and reach teacher dashboard" do
    visit new_user_session_path

    # Devise login form fields from your view:
    select "Teacher", from: "Role"
    fill_in "Username or Email", with: @teacher.email

    # Disambiguate password field if necessary
    find('input[name="user[password]"]').set(TEST_PASSWORD)

    click_button "Log in"

    # After sign in you route teachers to teacher_dashboard_path
    assert_current_path teacher_dashboard_path

    # Optional smoke assertion:
    # assert_text "Teacher Dashboard"
  end
end
