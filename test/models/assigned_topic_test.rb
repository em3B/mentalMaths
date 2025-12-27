require "test_helper"

class AssignedTopicTest < ActiveSupport::TestCase
  def setup
    @topic = Topic.create!(title: "Fake", category: "Addition and Subtraction")

    @teacher = User.create!(
      username: "teacher",
      email: "teacher@example.com",
      password: "password",
      role: "teacher"
    )

    @family = User.create!(
      username: "family",
      email: "family@example.com",
      password: "password",
      role: "family"
    )

    @student = User.create!(
      username: "student",
      email: "student@example.com",
      password: "password",
      role: "student"
    )

    @classroom = Classroom.create!(name: "Year 5", teacher_id: @teacher.id)
  end

  test "is valid when assigning to a user with authorized assigned_by" do
    record = AssignedTopic.new(topic: @topic, assigned_by: @teacher, user: @student)

    assert record.valid?, "Expected record to be valid, got errors: #{record.errors.full_messages}"
  end

  test "is valid when assigning to a classroom with authorized assigned_by" do
    record = AssignedTopic.new(topic: @topic, assigned_by: @teacher, classroom: @classroom)

    assert record.valid?, "Expected record to be valid, got errors: #{record.errors.full_messages}"
  end

  test "is invalid when neither user nor classroom is present" do
    record = AssignedTopic.new(topic: @topic, assigned_by: @teacher, user: nil, classroom: nil)

    assert_not record.valid?, "Expected record to be invalid"
    assert_includes record.errors[:user_id], "can't be blank"
    assert_includes record.errors[:classroom_id], "can't be blank"
  end

  test "assigned_by must be teacher or family - teacher passes" do
    record = AssignedTopic.new(topic: @topic, assigned_by: @teacher, user: @student)

    assert record.valid?, "Expected teacher to be authorized, got errors: #{record.errors.full_messages}"
  end

  test "assigned_by must be teacher or family - family passes" do
    record = AssignedTopic.new(topic: @topic, assigned_by: @family, user: @student)

    assert record.valid?, "Expected family to be authorized, got errors: #{record.errors.full_messages}"
  end

  test "assigned_by must be teacher or family - student fails" do
    record = AssignedTopic.new(topic: @topic, assigned_by: @student, user: @student)

    assert_not record.valid?, "Expected student assigned_by to be invalid"
    assert_includes record.errors[:assigned_by], "must be a teacher or family user"
  end

  test "assigned_by nil fails with authorization error" do
    record = AssignedTopic.new(topic: @topic, assigned_by: nil, user: @student)

    assert_not record.valid?, "Expected nil assigned_by to be invalid"
    assert_includes record.errors[:assigned_by], "must be a teacher or family user"
  end

  test "is valid when both user and classroom are present" do
    record = AssignedTopic.new(
      topic: @topic,
      assigned_by: @teacher,
      user: @student,
      classroom: @classroom
    )

    assert record.valid?, "Expected record to be valid when both user and classroom are present"
  end
end
