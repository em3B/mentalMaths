require "test_helper"

class CapacityRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "Password123!",
      username: "testuser",
      role: "teacher" # remove if your User doesn't have role
    )
  end

  # ---- AUTH -----------------------------------------------------------------

  test "redirects to sign in when logged out (new)" do
    get new_capacity_request_url
    assert_redirected_to new_user_session_path
  end

  test "redirects to sign in when logged out (create)" do
    post capacity_requests_url, params: { capacity_request: { request_type: 0, quantity: 5 } }
    assert_redirected_to new_user_session_path
  end

  # ---- NEW ------------------------------------------------------------------

  test "should get new when signed in" do
    sign_in @user
    get new_capacity_request_url
    assert_response :success
  end

  test "new pre-fills request_type and quantity from params when valid" do
    sign_in @user

    get new_capacity_request_url, params: { request_type: "0", quantity: "7" }
    assert_response :success

    # quantity should be prefilled
    assert_select 'input[name="capacity_request[quantity]"][value="7"]', 1

    # request_type might be a select or radio buttons depending on your form.
    # These cover the common cases:
    assert_select 'select[name="capacity_request[request_type]"] option[selected][value="0"]', 1
  rescue Minitest::Assertion
    # Fallback if request_type is rendered as radio buttons instead of a select:
    assert_select 'input[type="radio"][name="capacity_request[request_type]"][value="0"][checked]', 1
  end

  test "new does not prefill quantity when param is zero or negative" do
    sign_in @user

    get new_capacity_request_url, params: { request_type: "0", quantity: "0" }
    assert_response :success

    # If quantity isn't set, Rails form helpers usually render value="" or omit value.
    # We'll accept either.
    assert_select 'input[name="capacity_request[quantity]"]' do |inputs|
      html = inputs.first.to_s
      assert(html.include?('value=""') || !html.include?('value="0"'), "expected quantity not to be prefilled with 0")
    end
  end

  # ---- CREATE ---------------------------------------------------------------

  test "should create capacity_request, send email, and redirect on success" do
    sign_in @user

    assert_difference("CapacityRequest.count", 1) do
      assert_emails 1 do
        post capacity_requests_url, params: {
          capacity_request: {
            request_type: 0,
            quantity: 5,
            reason: "For testing",
            additional_info: "Extra info"
          }
        }
      end
    end

    assert_redirected_to root_path
    assert_equal "Your request has been submitted. We'll review it soon!", flash[:notice]
  end

  test "should not send email and should render new with 422 when invalid" do
    sign_in @user

    assert_no_difference("CapacityRequest.count") do
      assert_emails 0 do
        post capacity_requests_url, params: {
          capacity_request: {
            request_type: nil,
            quantity: nil,
            reason: ""
          }
        }
      end
    end

    assert_response :unprocessable_entity
  end
end
