require "test_helper"
require "ostruct"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      role: "teacher",
      username: "teacher_#{SecureRandom.hex(4)}"
    )

    @family = User.create!(
      email: "family-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      role: "family",
      username: "family_#{SecureRandom.hex(4)}"
    )

    @student = User.create!(
      email: "student-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      role: "student",
      username: "student_#{SecureRandom.hex(4)}"
    )
  end

  # ---- AUTH / AUTHZ ---------------------------------------------------------

  test "redirects to sign in when logged out" do
    get edit_payment_method_path
    assert_redirected_to new_user_session_path
  end

  test "student is blocked from edit" do
    sign_in @student
    get edit_payment_method_path
    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "teacher can view edit" do
    sign_in @teacher
    get edit_payment_method_path
    assert_response :success
  end

  test "family can view edit" do
    sign_in @family
    get edit_payment_method_path
    assert_response :success
  end

  # ---- UPDATE ---------------------------------------------------------------

  test "update creates stripe customer when missing and updates user + redirects" do
    sign_in @teacher

    customer = OpenStruct.new(id: "cus_123")
    subscription = OpenStruct.new(
      id: "sub_123",
      status: "active",
      current_period_end: Time.now.to_i + 30.days.to_i
    )

    StripeCustomerWrapper.stubs(:create).returns(customer)
    StripeCustomerWrapper.stubs(:retrieve).raises("should not be called")

    StripeSubscriptionWrapper.stubs(:create).returns(subscription)

    patch payment_method_path, params: { payment_method: "pm_123" }

    assert_redirected_to profile_path
    assert_equal "Account created and subscription active!", flash[:notice]

    @teacher.reload
    assert_equal "cus_123", @teacher.stripe_customer_id
    assert_equal "sub_123", @teacher.stripe_subscription_id
    assert_equal "active", @teacher.billing_status
    assert_equal "Basic Plan", @teacher.plan_name
    assert_equal false, @teacher.pending_payment
    assert @teacher.subscription_ends_at.present?
  end

  test "update retrieves stripe customer when present and does not create" do
    @teacher.update!(stripe_customer_id: "cus_existing")
    sign_in @teacher

    StripeCustomerWrapper.stubs(:retrieve).with("cus_existing").returns(OpenStruct.new(id: "cus_existing"))
    StripeCustomerWrapper.stubs(:create).raises("should not be called")

    StripeSubscriptionWrapper.stubs(:create).returns(
      OpenStruct.new(
        id: "sub_456",
        status: "active",
        current_period_end: Time.now.to_i + 30.days.to_i
      )
    )

    patch payment_method_path, params: { payment_method: "pm_123" }

    assert_redirected_to profile_path

    @teacher.reload
    assert_equal "cus_existing", @teacher.stripe_customer_id
    assert_equal "sub_456", @teacher.stripe_subscription_id
  end

  test "update handles Stripe card error by rendering edit with alert" do
    sign_in @teacher

    StripeCustomerWrapper.stubs(:create).returns(OpenStruct.new(id: "cus_123"))
    StripeSubscriptionWrapper.stubs(:create).raises(Stripe::CardError.new("Your card was declined.", nil))

    patch payment_method_path, params: { payment_method: "pm_bad" }

    assert_response :success
    assert_equal "Your card was declined.", flash[:alert]
  end

  test "student is blocked from update" do
    sign_in @student

    patch payment_method_path, params: { payment_method: "pm_123" }

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end
end
