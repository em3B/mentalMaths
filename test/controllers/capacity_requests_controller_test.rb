require "test_helper"

class CapacityRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers  # make Devise helpers available

  def setup
    @user = users(:one)   # replace with a valid fixture
    sign_in @user
  end

  test "should get new" do
    get new_capacity_request_url
    assert_response :success
  end

  test "should create capacity_request" do
    assert_difference("CapacityRequest.count") do
      post capacity_requests_url, params: { capacity_request: { name: "Test" } }
    end
    assert_redirected_to capacity_request_url(CapacityRequest.last)
  end
end
