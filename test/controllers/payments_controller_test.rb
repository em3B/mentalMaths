require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "teacher@example.com",
      password: "password123",
      role: "teacher",
      username: "test"
    )

    # Sign in user
    sign_in @user

    # Stub the payment methods on the user instance
    def @user.payment_method
      nil
    end

    def @user.update_payment_method(_params)
      true
    end
  end

  test "should get edit" do
    get edit_payment_method_url
    assert_response :success
  end

  test "should update payment method" do
    patch payment_method_url, params: { payment_method: "test-token" }
    assert_redirected_to profile_path
  end
end
