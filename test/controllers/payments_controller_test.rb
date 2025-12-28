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

  test "redirects to sign in when logged out" do
    get edit_payments_path
    assert_redirected_to new_user_session_path
  end

  test "student is blocked from edit" do
    sign_in @student
    get edit_payments_path
    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "teacher can view edit" do
    sign_in @teacher
    get edit_payments_path
    assert_response :success
  end

  test "family can view edit" do
    sign_in @family
    get edit_payments_path
    assert_response :success
  end

  test "create creates stripe customer when missing and redirects to checkout url" do
    sign_in @teacher

    customer = OpenStruct.new(id: "cus_123")
    StripeCustomerWrapper.stubs(:create).returns(customer)
    StripeCustomerWrapper.stubs(:retrieve).raises("should not be called")

    checkout_session = OpenStruct.new(url: "https://checkout.stripe.com/c/pay/cs_test_123")
    Stripe::Checkout::Session.stubs(:create).returns(checkout_session)

    post payments_path, params: { legal_acceptance: "1" }

    assert_redirected_to "https://checkout.stripe.com/c/pay/cs_test_123"
    @teacher.reload
    assert_equal "cus_123", @teacher.stripe_customer_id
  end

  test "create retrieves stripe customer when present and does not create" do
    @teacher.update!(stripe_customer_id: "cus_existing")
    sign_in @teacher

    StripeCustomerWrapper.stubs(:retrieve).with("cus_existing").returns(OpenStruct.new(id: "cus_existing"))
    StripeCustomerWrapper.stubs(:create).raises("should not be called")

    Stripe::Checkout::Session.stubs(:create).returns(
      OpenStruct.new(url: "https://checkout.stripe.com/c/pay/cs_test_456")
    )

    post payments_path, params: { legal_acceptance: "1" }

    assert_redirected_to "https://checkout.stripe.com/c/pay/cs_test_456"
    @teacher.reload
    assert_equal "cus_existing", @teacher.stripe_customer_id
  end

  test "success retrieves session + subscription and updates user then redirects" do
    sign_in @teacher

    fake_session = OpenStruct.new(subscription: "sub_123")
    Stripe::Checkout::Session.stubs(:retrieve).with("cs_test_123").returns(fake_session)

    subscription = OpenStruct.new(
      id: "sub_123",
      status: "active",
      current_period_end: Time.now.to_i + 30.days.to_i
    )
    Stripe::Subscription.stubs(:retrieve).with("sub_123").returns(subscription)

    get success_payments_path, params: { session_id: "cs_test_123" }

    assert_redirected_to profile_path
    assert_equal "Subscription active!", flash[:notice]

    @teacher.reload
    assert_equal "sub_123", @teacher.stripe_subscription_id
    assert_equal "active", @teacher.billing_status
    assert_equal "Teacher Plan", @teacher.plan_name
    assert_equal false, @teacher.pending_payment
    assert @teacher.subscription_ends_at.present?
  end

  test "cancel redirects to profile with alert" do
    sign_in @teacher

    get cancel_payments_path

    assert_redirected_to profile_path
    assert_equal "Checkout cancelled.", flash[:alert]
  end

  test "portal redirects to stripe billing portal session url when customer exists" do
    sign_in @teacher
    @teacher.update!(stripe_customer_id: "cus_123")

    Stripe::BillingPortal::Session.stubs(:create).returns(
      OpenStruct.new(url: "https://billing.stripe.com/session/test_123")
    )

    post portal_payments_path

    assert_redirected_to "https://billing.stripe.com/session/test_123"
  end

  test "portal redirects back with alert when no stripe customer id" do
    sign_in @teacher
    @teacher.update!(stripe_customer_id: nil)

    post portal_payments_path

    assert_redirected_to edit_payments_path
    assert_equal "No billing profile found yet. Start a subscription first.", flash[:alert]
  end

  test "student is blocked from create" do
    sign_in @student

    post payments_path, params: { legal_acceptance: "1" }

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "student is blocked from portal" do
    sign_in @student

    post portal_payments_path

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "create requires legal acceptance" do
    sign_in @teacher

    StripeCustomerWrapper.stubs(:create).raises("should not be called")
    StripeCustomerWrapper.stubs(:retrieve).raises("should not be called")
    Stripe::Checkout::Session.stubs(:create).raises("should not be called")

    post payments_path # no legal_acceptance

    assert_redirected_to edit_payments_path
    assert_equal "Please agree to the Terms of Service and Privacy Policy to continue.", flash[:alert]

    @teacher.reload
    assert_nil @teacher.terms_accepted_at
    assert_nil @teacher.privacy_accepted_at
  end
end
