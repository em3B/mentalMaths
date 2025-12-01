require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get teacher dashboard" do
    get teacher_dashboard_url
    assert_response :success
  end

  test "should get family dashboard" do
    get family_dashboard_url
    assert_response :success
  end
end
