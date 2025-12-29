require "test_helper"

class SchoolTest < ActiveSupport::TestCase
  TEST_PASSWORD = "correct-horse-battery-staple-42"

  def setup
    @school = School.new(
      name: "Test School",
      contact_email: "admin@testschool.com",
      seat_limit: 2
    )
  end

  def confirm_for_devise!(user)
    user.update!(confirmed_at: Time.current) if user.class.column_names.include?("confirmed_at")
    user.update!(locked_at: nil)            if user.class.column_names.include?("locked_at")
    user
  end

  # -------------------------
  # Associations
  # -------------------------

  test "has_many users" do
    reflection = School.reflect_on_association(:users)
    assert_equal :has_many, reflection.macro
  end

  test "has_many school_invitations dependent destroy" do
    reflection = School.reflect_on_association(:school_invitations)
    assert_equal :has_many, reflection.macro
    assert_equal :destroy, reflection.options[:dependent]
  end

  test "destroying a school destroys its invitations" do
    school = School.create!(name: "Destroy Me", contact_email: "destroy@school.com")

    invitation = SchoolInvitation.create!(
      school: school,
      email: "teacher@example.com",
      token: "token-123"
    )

    assert SchoolInvitation.exists?(invitation.id), "Expected invitation to exist before school deletion"

    school.destroy!

    assert_not SchoolInvitation.exists?(invitation.id), "Expected invitation to be destroyed when school is destroyed"
  end

  # -------------------------
  # Validations
  # -------------------------

  test "is valid with name and contact_email" do
    assert @school.valid?, "Expected school to be valid, got errors: #{@school.errors.full_messages}"
  end

  test "is invalid without name" do
    school = School.new(contact_email: "admin@testschool.com")
    assert_not school.valid?
    assert_includes school.errors[:name], "can't be blank"
  end

  test "is invalid without contact_email" do
    school = School.new(name: "Test School", contact_email: nil)
    assert_not school.valid?
    assert_includes school.errors[:contact_email], "can't be blank"
  end

  test "is invalid when contact_email format is bad" do
    school = School.new(name: "Test School", contact_email: "not-an-email")
    assert_not school.valid?
    assert_includes school.errors[:contact_email], "is invalid"
  end

  test "allows blank contact_email to hit presence validation rather than format validation" do
    school = School.new(name: "Test School", contact_email: "")
    assert_not school.valid?
    assert_includes school.errors[:contact_email], "can't be blank"
  end

  # -------------------------
  # active_subscription?
  # -------------------------

  test "active_subscription? is true when billing_status is active and subscription_ends_at is nil" do
    school = School.new(
      name: "Test School",
      contact_email: "admin@testschool.com",
      billing_status: "active",
      subscription_ends_at: nil
    )

    assert school.active_subscription?
  end

  test "active_subscription? is true when billing_status is trialing and subscription_ends_at is in the future" do
    school = School.new(
      name: "Test School",
      contact_email: "admin@testschool.com",
      billing_status: "trialing",
      subscription_ends_at: 2.days.from_now
    )

    assert school.active_subscription?
  end

  test "active_subscription? is false when billing_status is active but subscription_ends_at is in the past" do
    school = School.new(
      name: "Test School",
      contact_email: "admin@testschool.com",
      billing_status: "active",
      subscription_ends_at: 2.days.ago
    )

    assert_not school.active_subscription?
  end

  test "active_subscription? is false when billing_status is not active or trialing" do
    school = School.new(
      name: "Test School",
      contact_email: "admin@testschool.com",
      billing_status: "canceled",
      subscription_ends_at: nil
    )

    assert_not school.active_subscription?
  end

  # -------------------------
  # Seat calculations
  # -------------------------

  test "seats_used counts only teacher users" do
    school = School.create!(name: "Seat School", contact_email: "seats@school.com", seat_limit: 5)

    confirm_for_devise!(User.create!(
      email: "t1-#{SecureRandom.hex(3)}@school.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "t1_#{SecureRandom.hex(3)}",
      role: "teacher",
      school: school
    ))

    confirm_for_devise!(User.create!(
      email: "t2-#{SecureRandom.hex(3)}@school.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "t2_#{SecureRandom.hex(3)}",
      role: "teacher",
      school: school
    ))

    confirm_for_devise!(User.create!(
      email: "s1-#{SecureRandom.hex(3)}@school.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "s1_#{SecureRandom.hex(3)}",
      role: "student",
      school: school
    ))

    assert_equal 2, school.seats_used
  end

  test "seats_available? is true when seat_limit is greater than teacher count" do
    school = School.create!(name: "Seat School", contact_email: "seats2@school.com", seat_limit: 2)

    confirm_for_devise!(User.create!(
      email: "t1b-#{SecureRandom.hex(3)}@school.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "t1b_#{SecureRandom.hex(3)}",
      role: "teacher",
      school: school
    ))

    assert school.seats_available?
  end

  test "seats_available? is false when seat_limit equals teacher count" do
    school = School.create!(name: "Seat School", contact_email: "seats3@school.com", seat_limit: 1)

    confirm_for_devise!(User.create!(
      email: "t1c-#{SecureRandom.hex(3)}@school.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "t1c_#{SecureRandom.hex(3)}",
      role: "teacher",
      school: school
    ))

    assert_not school.seats_available?
  end

  test "seats_available? is false when seat_limit is less than teacher count" do
    school = School.create!(name: "Seat School", contact_email: "seats4@school.com", seat_limit: 1)

    confirm_for_devise!(User.create!(
      email: "t1d-#{SecureRandom.hex(3)}@school.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "t1d_#{SecureRandom.hex(3)}",
      role: "teacher",
      school: school
    ))

    confirm_for_devise!(User.create!(
      email: "t2d-#{SecureRandom.hex(3)}@school.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      username: "t2d_#{SecureRandom.hex(3)}",
      role: "teacher",
      school: school
    ))

    assert_not school.seats_available?
  end
end
