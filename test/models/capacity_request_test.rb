require "test_helper"

class CapacityRequestTest < ActiveSupport::TestCase
  TEST_PASSWORD = "correct-horse-battery-staple-42"

  def setup
    @user = confirm_for_devise!(User.create!(
      email: "ex-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_user_#{SecureRandom.hex(3)}",
      role: "teacher"
    ))
  end

  def confirm_for_devise!(user)
    user.update!(confirmed_at: Time.current) if user.class.column_names.include?("confirmed_at")
    user.update!(locked_at: nil)            if user.class.column_names.include?("locked_at")
    user
  end

  test "belongs_to user" do
    reflection = CapacityRequest.reflect_on_association(:user)
    assert_equal :belongs_to, reflection.macro
  end

  test "defaults status to pending on initialize when status is nil" do
    req = CapacityRequest.new(
      user: @user,
      request_type: 0,
      quantity: 1,
      reason: "Need more capacity"
    )

    assert_equal "pending", req.status
  end

  test "does not override status if already set" do
    req = CapacityRequest.new(
      status: "approved",
      user: @user,
      request_type: 0,
      quantity: 1,
      reason: "Need more capacity"
    )

    assert_equal "approved", req.status
  end

  test "is valid with valid attributes" do
    req = CapacityRequest.new(
      user: @user,
      request_type: 1,
      quantity: 3,
      reason: "More students joining"
    )

    assert req.valid?, "Expected valid request, got errors: #{req.errors.full_messages}"
  end

  test "is invalid without request_type" do
    req = CapacityRequest.new(
      user: @user,
      request_type: nil,
      quantity: 1,
      reason: "Because"
    )

    assert_not req.valid?
    assert_includes req.errors[:request_type], "can't be blank"
  end

  test "is invalid with request_type not in allowed list" do
    req = CapacityRequest.new(
      user: @user,
      request_type: 99,
      quantity: 1,
      reason: "Because"
    )

    assert_not req.valid?
    assert_includes req.errors[:request_type], "is not included in the list"
  end

  test "is invalid when quantity is not an integer" do
    req = CapacityRequest.new(
      user: @user,
      request_type: 0,
      quantity: 1.5,
      reason: "Because"
    )

    assert_not req.valid?
    assert_includes req.errors[:quantity], "must be an integer"
  end

  test "is invalid when quantity is zero or negative" do
    [ 0, -1 ].each do |qty|
      req = CapacityRequest.new(
        user: @user,
        request_type: 0,
        quantity: qty,
        reason: "Because"
      )

      assert_not req.valid?
      assert_includes req.errors[:quantity], "must be greater than 0"
    end
  end

  test "is invalid without reason" do
    req = CapacityRequest.new(
      user: @user,
      request_type: 0,
      quantity: 1,
      reason: nil
    )

    assert_not req.valid?
    assert_includes req.errors[:reason], "can't be blank"
  end

  # -------------------------
  # Helper methods
  # -------------------------

  test "request_type_value returns the stored integer" do
    req = CapacityRequest.new(user: @user, request_type: 2, quantity: 1, reason: "Because")
    assert_equal 2, req.request_type_value
  end

  test "request_type_symbol returns the matching symbol" do
    req = CapacityRequest.new(user: @user, request_type: 1, quantity: 1, reason: "Because")
    assert_equal :student, req.request_type_symbol
  end

  test "request_type_name returns the correct string name" do
    req = CapacityRequest.new(user: @user, request_type: 0, quantity: 1, reason: "Because")
    assert_equal "classroom", req.request_type_name
  end

  test "request_type_name returns unknown for invalid values" do
    req = CapacityRequest.new(user: @user, request_type: 999, quantity: 1, reason: "Because")
    assert_equal "unknown", req.request_type_name
  end
end
