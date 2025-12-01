require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Create a teacher user
    @teacher = User.create!(
      email: "teacher@example.com",
      password: "password",
      username: "teacheruser",
      role: "teacher"
    )

    # Create a family user
    @family = User.create!(
      email: "family@example.com",
      password: "password",
      username: "familyuser",
      role: "family"
    )
  end

  test "should get teacher dashboard" do
    sign_in @teacher
    get teacher_dashboard_url
    assert_response :success
  end

  test "should get family dashboard" do
    sign_in @family
    get family_dashboard_url
    assert_response :success
  end
end
