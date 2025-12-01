require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)  # or create a user with FactoryBot if you prefer
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
