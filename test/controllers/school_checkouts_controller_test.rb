require "test_helper"
require "ostruct"

class SchoolCheckoutsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  TEST_PASSWORD = "correct-horse-battery-staple-42"

  setup do
    @school = School.create!(
      name: "Test School",
      contact_email: "billing@test-school.example",
      stripe_customer_id: nil
    )

    @teacher_bootstrap = confirm_for_devise!(User.create!(
      email: "teacher-bootstrap-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_bootstrap_#{SecureRandom.hex(4)}",
      role: "teacher",
      school: @school,
      school_admin: false
    ))

    @school_admin = confirm_for_devise!(User.create!(
      email: "school-admin-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "school_admin_#{SecureRandom.hex(4)}",
      role: "teacher",
      school: @school,
      school_admin: true
    ))

    @teacher_not_admin_same_school = confirm_for_devise!(User.create!(
      email: "teacher-nonadmin-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_nonadmin_#{SecureRandom.hex(4)}",
      role: "teacher",
      school: @school,
      school_admin: false
    ))

    @other_school = School.create!(
      name: "Other School",
      contact_email: "billing@other-school.example",
      stripe_customer_id: nil
    )

    @other_school_admin = confirm_for_devise!(User.create!(
      email: "other-admin-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "other_admin_#{SecureRandom.hex(4)}",
      role: "teacher",
      school: @other_school,
      school_admin: true
    ))
  end

  def confirm_for_devise!(user)
    user.update!(confirmed_at: Time.current) if user.class.column_names.include?("confirmed_at")
    user.update!(locked_at: nil)            if user.class.column_names.include?("locked_at")
    user
  end

  # ---- AUTH -----------------------------------------------------------------

  test "logged out user is redirected to sign in" do
    post school_checkout_path(@school), params: { seats: 3 }
    assert_redirected_to new_user_session_path
  end

  # ---- AUTHZ / BOOTSTRAP ----------------------------------------------------

  test "teacher in same school can bootstrap checkout when no school admin exists yet" do
    # Ensure no admin exists for this school
    User.where(school_id: @school.id).update_all(school_admin: false)

    sign_in @teacher_bootstrap

    StripeCustomerWrapper.stubs(:create).returns(OpenStruct.new(id: "cus_123"))
    StripeCustomerWrapper.stubs(:retrieve).raises("should not be called")

    Stripe::Checkout::Session.stubs(:create).returns(OpenStruct.new(url: "https://checkout.stripe.com/pay/cs_bootstrap"))

    post school_checkout_path(@school), params: { seats: 2 }

    assert_redirected_to "https://checkout.stripe.com/pay/cs_bootstrap"
  end

  test "teacher in same school who is not admin is denied when an admin exists" do
    # admin exists via @school_admin
    sign_in @teacher_not_admin_same_school

    post school_checkout_path(@school), params: { seats: 2 }

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "admin of another school is denied" do
    sign_in @other_school_admin

    post school_checkout_path(@school), params: { seats: 2 }

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  # ---- CREATE ---------------------------------------------------------------

  test "create uses StripeCustomerWrapper.create when school has no stripe_customer_id, stores it, and redirects to Stripe session url" do
    sign_in @school_admin

    StripeCustomerWrapper.stubs(:retrieve).raises("should not be called")
    StripeCustomerWrapper.stubs(:create).returns(OpenStruct.new(id: "cus_123"))

    Stripe::Checkout::Session.stubs(:create).returns(OpenStruct.new(url: "https://checkout.stripe.com/pay/cs_test_123"))

    post school_checkout_path(@school), params: { seats: 2 }

    @school.reload
    assert_equal "cus_123", @school.stripe_customer_id
    assert_redirected_to "https://checkout.stripe.com/pay/cs_test_123"
  end

  test "create uses StripeCustomerWrapper.retrieve when school already has stripe_customer_id" do
    @school.update!(stripe_customer_id: "cus_existing")
    sign_in @school_admin

    StripeCustomerWrapper.stubs(:retrieve).with("cus_existing").returns(OpenStruct.new(id: "cus_existing"))
    StripeCustomerWrapper.stubs(:create).raises("should not be called")

    Stripe::Checkout::Session.stubs(:create).returns(OpenStruct.new(url: "https://checkout.stripe.com/pay/cs_test_456"))

    post school_checkout_path(@school), params: { seats: 3 }

    @school.reload
    assert_equal "cus_existing", @school.stripe_customer_id
    assert_redirected_to "https://checkout.stripe.com/pay/cs_test_456"
  end

  test "create forces seats to minimum of 1 when seats is 0 and includes metadata" do
    sign_in @school_admin

    StripeCustomerWrapper.stubs(:create).returns(OpenStruct.new(id: "cus_123"))

    captured = nil
    Stripe::Checkout::Session.stubs(:create).with { |args|
      captured = args
      true
    }.returns(OpenStruct.new(url: "https://checkout.stripe.com/pay/cs_test_min1"))

    post school_checkout_path(@school), params: { seats: 0 }

    assert_redirected_to "https://checkout.stripe.com/pay/cs_test_min1"
    refute_nil captured, "expected Stripe::Checkout::Session.create to be called"

    assert_equal "subscription", captured[:mode]
    assert_equal "cus_123", captured[:customer]

    assert_equal @school.id, captured.dig(:metadata, :school_id)
    assert_equal @school_admin.id, captured.dig(:metadata, :initiated_by_user_id)

    assert_equal 1, captured[:line_items].first[:quantity]
  end

  # ---- SUCCESS / CANCEL -----------------------------------------------------

  test "success redirects back to school with notice" do
    sign_in @school_admin

    get schools_checkout_success_path, params: { school_id: @school.id }

    assert_redirected_to school_path(@school)
    assert_equal "School subscription started.", flash[:notice]
  end

  test "cancel redirects back to school with alert" do
    sign_in @school_admin

    get schools_checkout_cancel_path, params: { school_id: @school.id }

    assert_redirected_to school_path(@school)
    assert_equal "Checkout cancelled.", flash[:alert]
  end
end
