require "test_helper"
require "ostruct"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "teacher@example.com",
      password: "password123",
      role: "teacher",
      username: "test"
    )

    sign_in @user
  end

  test "should update payment method" do
    # Stub the Stripe wrappers properly
    StripeCustomerWrapper.stubs(:create).returns(OpenStruct.new(id: "cus_123"))
    StripeCustomerWrapper.stubs(:retrieve).returns(OpenStruct.new(id: "cus_123"))

    StripeSubscriptionWrapper.stubs(:create).returns(
      OpenStruct.new(
        id: "sub_123",
        status: "active",
        current_period_end: Time.now.to_i + 1.month
      )
    )

    patch payment_method_path, params: { payment_method: "pm_123" }

    assert_redirected_to profile_path
  end
end
