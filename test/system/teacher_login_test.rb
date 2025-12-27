require "application_system_test_case"

class TeacherLoginTest < ApplicationSystemTestCase
  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher"
    )
  end

  test "teacher can log in and reach teacher dashboard" do
    visit new_user_session_path

    # Devise login form fields from your view:
    select "Teacher", from: "Role"
    fill_in "Username or Email", with: @teacher.email
    fill_in "Password", with: "Password123!"
    click_button "Log in"

    # After sign in you route teachers to teacher_dashboard_path in ApplicationController
    assert_current_path teacher_dashboard_path
    # If your page has a heading or text, assert it here (optional):
    # assert_text "Dashboard"
  end
end
