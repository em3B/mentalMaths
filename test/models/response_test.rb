require "test_helper"

class ResponseTest < ActiveSupport::TestCase
  def setup
    @topic = Topic.create!(title: "Fake", category: "Addition and Subtraction")
    @question = Question.create!(topic: @topic, question_text: "2 + 2?", correct_answer: 4)

    @user = User.create!(
      email: "student@example.com",
      password: "password",
      username: "student_1",
      role: "student"
    )
  end

  # -------------------------
  # Associations
  # -------------------------

  test "belongs_to question" do
    reflection = Response.reflect_on_association(:question)
    assert_equal :belongs_to, reflection.macro
  end

  test "belongs_to user (required)" do
    reflection = Response.reflect_on_association(:user)
    assert_equal :belongs_to, reflection.macro
    assert_nil reflection.options[:optional], "Expected user association to be required (no optional: true)"
  end

  # -------------------------
  # Validations
  # -------------------------

  test "is valid with question, user, and value" do
    response = Response.new(question: @question, user: @user, value: 4)
    assert response.valid?, "Expected response to be valid, got errors: #{response.errors.full_messages}"
  end

  test "is invalid without value" do
    response = Response.new(question: @question, user: @user, value: nil)

    assert_not response.valid?
    assert_includes response.errors[:value], "can't be blank"
  end

  test "is invalid without user" do
    response = Response.new(question: @question, user: nil, value: 4)

    assert_not response.valid?
    assert_includes response.errors[:user], "must exist"
  end

  test "is invalid without question" do
    response = Response.new(question: nil, user: @user, value: 4)

    assert_not response.valid?
    assert_includes response.errors[:question], "must exist"
  end
end
