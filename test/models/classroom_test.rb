require "test_helper"

class ClassroomTest < ActiveSupport::TestCase
  TEST_PASSWORD = "correct-horse-battery-staple-42"

  def setup
    @teacher = confirm_for_devise!(User.create!(
      email: "teacher-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_#{SecureRandom.hex(3)}",
      role: "teacher",
      capacity_limits: { "classroom" => 10, "student" => 40 } # override per test when needed
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

  test "belongs_to teacher (User)" do
    reflection = Classroom.reflect_on_association(:teacher)
    assert_equal :belongs_to, reflection.macro
    assert_equal "User", reflection.class_name
  end

  test "has_many students (User) dependent nullify" do
    reflection = Classroom.reflect_on_association(:students)
    assert_equal :has_many, reflection.macro
    assert_equal "User", reflection.class_name
    assert_equal :nullify, reflection.options[:dependent]
  end

  test "has_many assigned_topics" do
    reflection = Classroom.reflect_on_association(:assigned_topics)
    assert_equal :has_many, reflection.macro
  end

  test "has_many topics through assigned_topics" do
    reflection = Classroom.reflect_on_association(:topics)
    assert_equal :has_many, reflection.macro
    assert_equal :assigned_topics, reflection.options[:through]
  end

  # -------------------------
  # Validation: classroom limit (on create)
  # -------------------------

  test "prevents creating a classroom when teacher is at classroom limit" do
    teacher = confirm_for_devise!(User.create!(
      email: "limited_teacher-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_limited_#{SecureRandom.hex(3)}",
      role: "teacher",
      capacity_limits: { "classroom" => 1, "student" => 40 }
    ))

    Classroom.create!(name: "Already there", teacher: teacher)

    new_classroom = Classroom.new(name: "Should fail", teacher: teacher)
    assert_not new_classroom.valid?, "Expected classroom creation to be blocked at limit"

    assert_includes(
      new_classroom.errors[:base],
      "You have reached your classroom limit of 1. You can submit a request for more."
    )
  end

  test "allows creating a classroom when teacher is under classroom limit" do
    teacher = confirm_for_devise!(User.create!(
      email: "ok_teacher-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_ok_#{SecureRandom.hex(3)}",
      role: "teacher",
      capacity_limits: { "classroom" => 2, "student" => 40 }
    ))

    Classroom.create!(name: "First", teacher: teacher)

    new_classroom = Classroom.new(name: "Second", teacher: teacher)
    assert new_classroom.valid?, "Expected classroom to be valid when under limit"
  end

  test "uses default classroom limit of 10 when teacher capacity_limits is nil" do
    teacher = confirm_for_devise!(User.create!(
      email: "default_teacher-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_default_#{SecureRandom.hex(3)}",
      role: "teacher",
      capacity_limits: nil
    ))

    10.times { |i| Classroom.create!(name: "C#{i}", teacher: teacher) }

    new_classroom = Classroom.new(name: "C11", teacher: teacher)
    assert_not new_classroom.valid?, "Expected 11th classroom to be blocked by default limit"

    assert_includes(
      new_classroom.errors[:base],
      "You have reached your classroom limit of 10. You can submit a request for more."
    )
  end

  test "does not run teacher classroom limit validation on update" do
    teacher = confirm_for_devise!(User.create!(
      email: "update_teacher-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_update_#{SecureRandom.hex(3)}",
      role: "teacher",
      capacity_limits: { "classroom" => 1, "student" => 40 }
    ))

    classroom = Classroom.create!(name: "Only", teacher: teacher)

    classroom.name = "Renamed"
    assert classroom.valid?, "Expected update to be allowed (create-only validation should not run)"
  end

  # -------------------------
  # Validation: student limit (on update)
  # -------------------------

  test "prevents update when classroom student count exceeds teacher student limit" do
    teacher = confirm_for_devise!(User.create!(
      email: "student_limit_teacher-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_student_limit_#{SecureRandom.hex(3)}",
      role: "teacher",
      capacity_limits: { "classroom" => 10, "student" => 2 }
    ))

    classroom = Classroom.create!(name: "Tiny class", teacher: teacher)

    3.times do |i|
      confirm_for_devise!(User.create!(
        email: "student#{i}-#{SecureRandom.hex(3)}@example.com",
        password: TEST_PASSWORD,
        password_confirmation: TEST_PASSWORD,
        username: "student_#{i}_#{SecureRandom.hex(3)}",
        role: "student",
        classroom_id: classroom.id
      ))
    end

    classroom.reload
    classroom.name = "Trigger update validation"

    assert_not classroom.valid?, "Expected update to be blocked when students exceed limit"
    assert_includes(
      classroom.errors[:base],
      "This classroom has reached your student limit of 2. You can submit a request for more."
    )
  end

  test "allows update when classroom student count is within teacher student limit" do
    teacher = confirm_for_devise!(User.create!(
      email: "student_ok_teacher-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_student_ok_#{SecureRandom.hex(3)}",
      role: "teacher",
      capacity_limits: { "classroom" => 10, "student" => 2 }
    ))

    classroom = Classroom.create!(name: "Small class", teacher: teacher)

    2.times do |i|
      confirm_for_devise!(User.create!(
        email: "okstudent#{i}-#{SecureRandom.hex(3)}@example.com",
        password: TEST_PASSWORD,
        password_confirmation: TEST_PASSWORD,
        username: "ok_student_#{i}_#{SecureRandom.hex(3)}",
        role: "student",
        classroom_id: classroom.id
      ))
    end

    classroom.reload
    classroom.name = "Rename"
    assert classroom.valid?, "Expected update to be allowed within student limit"
  end

  test "uses default student limit of 40 when teacher capacity_limits is nil" do
    teacher = confirm_for_devise!(User.create!(
      email: "default_student_teacher-#{SecureRandom.hex(3)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "teacher_default_student_#{SecureRandom.hex(3)}",
      role: "teacher",
      capacity_limits: nil
    ))

    classroom = Classroom.create!(name: "Big class", teacher: teacher)

    41.times do |i|
      confirm_for_devise!(User.create!(
        email: "bigstudent#{i}-#{SecureRandom.hex(3)}@example.com",
        password: TEST_PASSWORD,
        password_confirmation: TEST_PASSWORD,
        username: "big_student_#{i}_#{SecureRandom.hex(3)}",
        role: "student",
        classroom_id: classroom.id
      ))
    end

    classroom.reload
    classroom.name = "Trigger update"
    assert_not classroom.valid?, "Expected update to be blocked when exceeding default 40 student limit"

    assert_includes(
      classroom.errors[:base],
      "This classroom has reached your student limit of 40. You can submit a request for more."
    )
  end
end
