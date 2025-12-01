require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "password",
      username: "testuser"
    )
    sign_in @user
  end

  test "should get teacher dashboard" do
    get teacher_dashboard_url
    assert_response :success
  end

  test "should get family dashboard" do
    get family_dashboard_url
    assert_response :success
  end
end
