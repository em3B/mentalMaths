require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  def setup
    @topic = Topic.create!(title: "Fake", category: "Addition and Subtraction")
  end

  # -------------------------
  # Associations
  # -------------------------

  test "belongs_to topic" do
    reflection = Question.reflect_on_association(:topic)
    assert_equal :belongs_to, reflection.macro
  end

  test "has_many responses dependent destroy" do
    reflection = Question.reflect_on_association(:responses)
    assert_equal :has_many, reflection.macro
    assert_equal :destroy, reflection.options[:dependent]
  end

  # -------------------------
  # Validations
  # -------------------------

  test "is valid with question_text and correct_answer" do
    question = Question.new(
      topic: @topic,
      question_text: "What is 1/2 + 1/4?",
      correct_answer: 3
    )

    assert question.valid?, "Expected question to be valid, got errors: #{question.errors.full_messages}"
  end

  test "is invalid without question_text" do
    question = Question.new(
      topic: @topic,
      question_text: nil,
      correct_answer: 3
    )

    assert_not question.valid?
    assert_includes question.errors[:question_text], "can't be blank"
  end

  test "is invalid without correct_answer" do
    question = Question.new(
      topic: @topic,
      question_text: "What is 2 + 2?",
      correct_answer: nil
    )

    assert_not question.valid?
    assert_includes question.errors[:correct_answer], "can't be blank"
  end

  # -------------------------
  # Dependent destroy behaviour
  # -------------------------

  test "destroying a question destroys its responses" do
    question = Question.create!(
      topic: @topic,
      question_text: "What is 2 + 2?",
      correct_answer: 4
    )

    user = User.create!(
      email: "student@example.com",
      password: "password",
      username: "student_1",
      role: "student"
    )

    response = Response.create!(
      question: question,
      user: user,
      value: 4
    )

    assert Response.exists?(response.id), "Expected response to exist before question deletion"

    question.destroy!

    assert_not Response.exists?(response.id), "Expected response to be destroyed when question is destroyed"
  end
end
