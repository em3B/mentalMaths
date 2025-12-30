require "test_helper"

class TopicTest < ActiveSupport::TestCase
  TEST_PASSWORD = "correct-horse-battery-staple-42"

  def setup
    @valid_category = Topic::CATEGORIES.first
  end

  def confirm_for_devise!(user)
    user.update!(confirmed_at: Time.current) if user.class.column_names.include?("confirmed_at")
    user.update!(locked_at: nil)            if user.class.column_names.include?("locked_at")
    user
  end

  # -------------------------
  # Associations
  # -------------------------

  test "has_many questions dependent destroy" do
    reflection = Topic.reflect_on_association(:questions)
    assert_equal :has_many, reflection.macro
    assert_equal :destroy, reflection.options[:dependent]
  end

  test "has_many scores" do
    reflection = Topic.reflect_on_association(:scores)
    assert_equal :has_many, reflection.macro
  end

  test "has_many assigned_topics" do
    reflection = Topic.reflect_on_association(:assigned_topics)
    assert_equal :has_many, reflection.macro
  end

  test "has_many students through assigned_topics with source user" do
    reflection = Topic.reflect_on_association(:students)
    assert_equal :has_many, reflection.macro
    assert_equal :assigned_topics, reflection.options[:through]
    assert_equal :user, reflection.options[:source]
  end

  # -------------------------
  # Validations
  # -------------------------

  test "is valid with title and allowed category" do
    topic = Topic.new(title: "Addition Basics", category: @valid_category)
    assert topic.valid?, "Expected topic to be valid, got errors: #{topic.errors.full_messages}"
  end

  test "is invalid without title" do
    topic = Topic.new(title: nil, category: @valid_category)

    assert_not topic.valid?
    assert_includes topic.errors[:title], "can't be blank"
  end

  test "is invalid without category" do
    topic = Topic.new(title: "Some Topic", category: nil)

    assert_not topic.valid?
    assert_includes topic.errors[:category], "can't be blank"
  end

  test "is invalid when category is not included" do
    topic = Topic.new(title: "Some Topic", category: "Not a real category")

    assert_not topic.valid?
    assert_includes topic.errors[:category], "is not included in the list"
  end

  test "title must be unique" do
    Topic.create!(title: "Unique Title", category: @valid_category)

    duplicate = Topic.new(title: "Unique Title", category: @valid_category)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:title], "has already been taken"
  end

  # -------------------------
  # Dependent destroy behaviour
  # -------------------------

  test "destroying a topic destroys its questions" do
    topic = Topic.create!(title: "Topic With Questions", category: @valid_category)

    q1 = Question.create!(topic: topic, question_text: "2+2?", correct_answer: 4)
    q2 = Question.create!(topic: topic, question_text: "3+3?", correct_answer: 6)

    assert Question.exists?(q1.id)
    assert Question.exists?(q2.id)

    topic.destroy!

    assert_not Question.exists?(q1.id)
    assert_not Question.exists?(q2.id)
  end

  # -------------------------
  # Through association behaviour (students)
  # -------------------------

  test "students returns users linked via assigned_topics" do
    teacher = confirm_for_devise!(User.create!(
      email: "t-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "t1_#{SecureRandom.hex(3)}",
      role: "teacher"
    ))

    student = confirm_for_devise!(User.create!(
      email: "s-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "s1_#{SecureRandom.hex(3)}",
      role: "student"
    ))

    topic = Topic.create!(title: "Topic For Students", category: @valid_category)

    AssignedTopic.create!(
      topic: topic,
      assigned_by: teacher,
      user: student
    )

    assert_includes topic.students, student
  end
end
