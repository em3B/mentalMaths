require "test_helper"

class CapacityRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get capacity_requests_new_url
    assert_response :success
  end

  test "should get create" do
    get capacity_requests_create_url
    assert_response :success
  end
end
