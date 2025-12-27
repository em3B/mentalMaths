require "test_helper"

class ScoreTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "student@example.com",
      password: "password",
      username: "student_1",
      role: "student"
    )

    @topic = Topic.create!(title: "Fake", category: "Addition and Subtraction")
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
