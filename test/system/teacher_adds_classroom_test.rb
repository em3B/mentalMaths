require "application_system_test_case"

class TeacherAddsClassroomTest < ApplicationSystemTestCase
  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher"
    )
  end

  test "teacher can add a classroom from the teacher dashboard" do
    visit new_user_session_path

    # ---- Login ---------------------------------------------------------------
    select "Teacher", from: "Role"
    fill_in "Username or Email", with: @teacher.email
    find('input[name="user[password]"]').set("Password123!")
    click_button "Log in"

    assert_current_path teacher_dashboard_path
    assert_text "Add a Classroom"

    # ---- Create classroom ----------------------------------------------------
    classroom_name = "Classroom #{SecureRandom.hex(3)}"
    find('input[placeholder="Classroom Name"]').set(classroom_name)
    click_button "Add"

    assert_text "Classroom created successfully."

    # ---- Verify via classrooms index ----------------------------------------
    # Your dashboard doesn't list classroom names, but it has a "My Classrooms" link.
    click_link "My Classrooms"

    # This page should list classrooms the teacher owns.
    assert_text classroom_name
  end
end
