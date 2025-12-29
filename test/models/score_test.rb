require "test_helper"

class ScoreTest < ActiveSupport::TestCase
  TEST_PASSWORD = "correct-horse-battery-staple-42"

  def setup
    @user = confirm_for_devise!(User.create!(
      email: "student-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "student_#{SecureRandom.hex(3)}",
      role: "student"
    ))

    @topic = Topic.create!(title: "Fake", category: "Addition and Subtraction")
  end

  def confirm_for_devise!(user)
    user.update!(confirmed_at: Time.current) if user.class.column_names.include?("confirmed_at")
    user.update!(locked_at: nil)            if user.class.column_names.include?("locked_at")
    user
  end

  # -------------------------
  # Associations
  # -------------------------

  test "belongs_to user" do
    reflection = Score.reflect_on_association(:user)
    assert_equal :belongs_to, reflection.macro
  end

  test "belongs_to topic" do
    reflection = Score.reflect_on_association(:topic)
    assert_equal :belongs_to, reflection.macro
  end

  # -------------------------
  # Required associations (Rails default for belongs_to)
  # -------------------------

  test "is valid with user and topic" do
    score = Score.new(user: @user, topic: @topic, correct: 3, total: 5)
    assert score.valid?, "Expected score to be valid, got errors: #{score.errors.full_messages}"
  end

  test "is invalid without user" do
    score = Score.new(user: nil, topic: @topic, correct: 3, total: 5)

    assert_not score.valid?
    assert_includes score.errors[:user], "must exist"
  end

  test "is invalid without topic" do
    score = Score.new(user: @user, topic: nil, correct: 3, total: 5)

    assert_not score.valid?
    assert_includes score.errors[:topic], "must exist"
  end
end
