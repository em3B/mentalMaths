require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @school = School.create!(name: "Test School", contact_email: "admin@testschool.com")
    @teacher = User.create!(
      email: "teacher@example.com",
      password: "password",
      username: "teacher_1",
      role: "teacher"
    )
  end

  # -------------------------
  # Associations (smoke checks via reflections)
  # -------------------------

  test "belongs_to school optional" do
    reflection = User.reflect_on_association(:school)
    assert_equal :belongs_to, reflection.macro
    assert_equal true, reflection.options[:optional]
  end

  test "belongs_to classroom optional" do
    reflection = User.reflect_on_association(:classroom)
    assert_equal :belongs_to, reflection.macro
    assert_equal true, reflection.options[:optional]
  end

  test "parent/children associations exist" do
    parent_ref = User.reflect_on_association(:parent)
    assert_equal :belongs_to, parent_ref.macro
    assert_equal "User", parent_ref.class_name
    assert_equal true, parent_ref.options[:optional]

    children_ref = User.reflect_on_association(:children)
    assert_equal :has_many, children_ref.macro
    assert_equal "User", children_ref.class_name
    assert_equal :nullify, children_ref.options[:dependent]
  end

  test "has_many classrooms as teacher with dependent destroy" do
    reflection = User.reflect_on_association(:classrooms)
    assert_equal :has_many, reflection.macro
    assert_equal "teacher_id", reflection.foreign_key.to_s
    assert_equal :destroy, reflection.options[:dependent]
  end

  test "has_many capacity_requests dependent destroy" do
    reflection = User.reflect_on_association(:capacity_requests)
    assert_equal :has_many, reflection.macro
    assert_equal :destroy, reflection.options[:dependent]
  end

  # -------------------------
  # Role helpers
  # -------------------------

  test "role predicate helpers" do
    teacher = User.new(role: "teacher")
    family  = User.new(role: "family")
    student = User.new(role: "student")

    assert teacher.teacher?
    assert family.family?
    assert student.student?
  end

  test "admin? reads the admin boolean" do
    u = User.new(admin: true)
    assert u.admin?

    u.admin = false
    assert_not u.admin?
  end

  # -------------------------
  # Capacity limits defaults + helpers
  # -------------------------

  test "capacity_limits defaults are set after initialize" do
    u = User.new(role: "teacher")
    assert_equal 10, u.capacity_limits["classroom"]
    assert_equal 40, u.capacity_limits["student"]
    assert_equal 10, u.capacity_limits["child"]
  end

  test "capacity_for returns value from capacity_limits or default" do
    u = User.new(capacity_limits: { "classroom" => 12 })
    assert_equal 12, u.capacity_for("classroom")
    assert_equal 40, u.capacity_for("student")
  end

  test "increment_capacity! increases and persists capacity_limits for the given type" do
    u = User.create!(
      email: "cap@example.com",
      password: "password",
      username: "cap_user",
      role: "teacher",
      capacity_limits: { "classroom" => 10, "student" => 40, "child" => 10 }
    )

    u.increment_capacity!(:student, 5)
    u.reload

    assert_equal 45, u.capacity_limits["student"]
  end

  # -------------------------
  # Validations: username uniqueness condition
  # -------------------------

  test "allows duplicate usernames when classroom_id is nil (per conditional uniqueness + partial index)" do
    a = User.create!(
      email: "u1@example.com",
      password: "password",
      username: "duplicate_name",
      role: "student",
      classroom_id: nil,
      created_by_family: true
    )

    b = User.new(
      email: "u2@example.com",
      password: "password",
      username: "duplicate_name",
      role: "student",
      classroom_id: nil,
      created_by_family: true
    )

    assert b.valid?, "Expected duplicate username to be allowed when classroom_id is nil, got errors: #{b.errors.full_messages}"
    assert b.save
  end

  test "rejects duplicate usernames when classroom_id is present" do
    classroom = Classroom.create!(name: "Year 5", teacher: @teacher)

    User.create!(
      email: "s1@example.com",
      password: "password",
      username: "unique_in_classroom",
      role: "student",
      classroom: classroom
    )

    dup = User.new(
      email: "s2@example.com",
      password: "password",
      username: "unique_in_classroom",
      role: "student",
      classroom: classroom
    )

    assert_not dup.valid?
    assert_includes dup.errors[:username], "has already been taken"
  end

  # -------------------------
  # Validations: email presence unless student_or_child?
  # -------------------------

  test "requires email for teacher" do
    u = User.new(username: "t_no_email", role: "teacher", password: "password", email: nil)
    assert_not u.valid?
    assert_includes u.errors[:email], "can't be blank"
  end

  test "does not require email for student created_by_family" do
    u = User.new(username: "kid_1", role: "student", password: "password", email: nil, created_by_family: true)
    assert u.valid?, "Expected student created_by_family to be valid without email, got errors: #{u.errors.full_messages}"
  end

  test "does not require email for child user (has a parent)" do
    parent = User.create!(email: "parent@example.com", password: "password", username: "parent_1", role: "family")

    child = User.new(
      username: "child_1",
      role: "student",
      password: "password",
      email: nil,
      parent: parent
    )

    assert child.valid?, "Expected child (parent present) to be valid without email, got errors: #{child.errors.full_messages}"
  end

  # -------------------------
  # soft_limit_children validation (runs on create if family?)
  # -------------------------

  test "soft_limit_children blocks creating a family user who is the (extra) child of a parent with 10 children" do
    parent = User.create!(email: "p@example.com", password: "password", username: "p1", role: "family")

    10.times do |i|
      User.create!(
        email: "child#{i}@example.com",
        password: "password",
        username: "child#{i}",
        role: "student",
        parent: parent
      )
    end

    # This matches your current implementation:
    # validation runs if the NEW user is family? and has a parent with >= 10 children
    extra = User.new(
      email: "extra@example.com",
      password: "password",
      username: "extra_child",
      role: "family",
      parent: parent
    )

    assert_not extra.valid?
    assert_includes(
      extra.errors[:base],
      "You have reached the recommended limit of 10 children. You can submit a request for more."
    )
  end

  # -------------------------
  # learner?
  # -------------------------

  test "learner? is true when student and created_by_family is true" do
    u = User.new(role: "student", created_by_family: true)
    assert u.learner?
  end

  test "learner? is true when student and classroom present" do
    classroom = Classroom.create!(name: "Year 6", teacher: @teacher)
    u = User.new(role: "student", classroom: classroom)
    assert u.learner?
  end

  test "learner? is false for teacher" do
    u = User.new(role: "teacher")
    assert_not u.learner?
  end

  # -------------------------
  # login behaviour
  # -------------------------

  test "login returns username for student created_by_family, otherwise email" do
    student = User.new(role: "student", created_by_family: true, username: "kiddo", email: nil)
    assert_equal "kiddo", student.login

    teacher = User.new(role: "teacher", username: "t1", email: "t1@example.com")
    assert_equal "t1@example.com", teacher.login
  end

  test "login= stores a custom login override" do
    u = User.new(role: "teacher", email: "t@example.com", username: "t1")
    u.login = "OVERRIDE"
    assert_equal "OVERRIDE", u.login
  end

  # -------------------------
  # premium_teacher?
  # -------------------------

  test "premium_teacher? true when teacher has active billing_status and subscription not ended" do
    u = User.new(
      role: "teacher",
      billing_status: "active",
      subscription_ends_at: 2.days.from_now
    )
    assert u.premium_teacher?
  end

  test "premium_teacher? false when teacher subscription ended" do
    u = User.new(
      role: "teacher",
      billing_status: "active",
      subscription_ends_at: 2.days.ago
    )
    assert_not u.premium_teacher?
  end

  test "premium_teacher? true when teacher has a school with active subscription" do
    school = School.create!(
      name: "Premium School",
      contact_email: "premium@school.com",
      billing_status: "active",
      subscription_ends_at: 2.days.from_now
    )

    u = User.new(role: "teacher", school: school, billing_status: "canceled")
    assert u.premium_teacher?
  end

  test "premium_teacher? false for non-teacher even if billing looks active" do
    u = User.new(role: "student", billing_status: "active", subscription_ends_at: 2.days.from_now)
    assert_not u.premium_teacher?
  end

  # -------------------------
  # find_for_database_authentication
  # -------------------------

  test "find_for_database_authentication finds by email or username case-insensitively within role" do
    user = User.create!(
      email: "Case@Test.com",
      password: "password",
      username: "CaseUser",
      role: "teacher"
    )

    found_by_email = User.find_for_database_authentication(login: "case@test.com", role: "teacher")
    assert_equal user.id, found_by_email&.id

    found_by_username = User.find_for_database_authentication(login: "caseuser", role: "teacher")
    assert_equal user.id, found_by_username&.id

    # should not return if role doesn't match
    found_wrong_role = User.find_for_database_authentication(login: "caseuser", role: "student")
    assert_nil found_wrong_role
  end
end
