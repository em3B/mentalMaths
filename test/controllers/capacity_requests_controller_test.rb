require "test_helper"

class CapacityRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers  # make Devise helpers available
  fixtures :users

  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "password",
      username: "testuser"
    )
    sign_in @user
  end

  test "should get new" do
    get new_capacity_request_url
    assert_response :success
  end

  test "should create capacity_request" do
    assert_difference("CapacityRequest.count", 1) do
      post capacity_requests_url, params: {
        capacity_request: {
          request_type: 0,
          quantity: 5,
          reason: "For testing",
          additional_info: "Extra info"
        }
      }
    end
    assert_redirected_to root_path
  end
end
