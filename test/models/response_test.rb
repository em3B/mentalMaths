require "test_helper"

class ResponseTest < ActiveSupport::TestCase
  TEST_PASSWORD = "correct-horse-battery-staple-42"

  def setup
    @topic = Topic.create!(title: "Fake", category: "Addition and Subtraction")
    @question = Question.create!(topic: @topic, question_text: "2 + 2?", correct_answer: 4)

    @user = confirm_for_devise!(User.create!(
      email: "student-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "student_#{SecureRandom.hex(3)}",
      role: "student"
    ))
  end

  def confirm_for_devise!(user)
    user.update!(confirmed_at: Time.current) if user.class.column_names.include?("confirmed_at")
    user.update!(locked_at: nil)            if user.class.column_names.include?("locked_at")
    user
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
