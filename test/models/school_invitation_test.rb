require "test_helper"

class SchoolInvitationTest < ActiveSupport::TestCase
  def setup
    @school = School.create!(
      name: "Test School",
      contact_email: "admin@testschool.com"
    )
  end

  # -------------------------
  # Associations
  # -------------------------

  test "belongs_to school" do
    reflection = SchoolInvitation.reflect_on_association(:school)
    assert_equal :belongs_to, reflection.macro
  end

  # -------------------------
  # Validations
  # -------------------------

  test "is valid with email, school, and generated token" do
    invitation = SchoolInvitation.new(
      school: @school,
      email: "teacher@example.com"
    )

    assert invitation.valid?, "Expected invitation to be valid, got errors: #{invitation.errors.full_messages}"
    assert invitation.token.present?, "Expected token to be generated before validation"
  end

  test "is invalid without email" do
    invitation = SchoolInvitation.new(
      school: @school,
      email: nil
    )

    assert_not invitation.valid?
    assert_includes invitation.errors[:email], "can't be blank"
  end

  test "is invalid without token" do
    invitation = SchoolInvitation.new(
      school: @school,
      email: "teacher@example.com",
      token: nil
    )

    # ensure_token runs before validation on create
    invitation.valid?
    assert invitation.token.present?, "Expected token to be set by callback"
  end

  test "enforces token uniqueness" do
    token = "unique-token"

    SchoolInvitation.create!(
      school: @school,
      email: "first@example.com",
      token: token
    )

    duplicate = SchoolInvitation.new(
      school: @school,
      email: "second@example.com",
      token: token
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:token], "has already been taken"
  end

  # -------------------------
  # Instance methods
  # -------------------------

  test "expired? returns false when expires_at is nil" do
    invitation = SchoolInvitation.new(
      school: @school,
      email: "teacher@example.com"
    )

    assert_not invitation.expired?
  end

  test "expired? returns false when expires_at is in the future" do
    invitation = SchoolInvitation.new(
      school: @school,
      email: "teacher@example.com",
      expires_at: 2.days.from_now
    )

    assert_not invitation.expired?
  end

  test "expired? returns true when expires_at is in the past" do
    invitation = SchoolInvitation.new(
      school: @school,
      email: "teacher@example.com",
      expires_at: 2.days.ago
    )

    assert invitation.expired?
  end

  test "accepted? returns false when accepted_at is nil" do
    invitation = SchoolInvitation.new(
      school: @school,
      email: "teacher@example.com"
    )

    assert_not invitation.accepted?
  end

  test "accepted? returns true when accepted_at is present" do
    invitation = SchoolInvitation.new(
      school: @school,
      email: "teacher@example.com",
      accepted_at: Time.current
    )

    assert invitation.accepted?
  end

  # -------------------------
  # Callback behaviour
  # -------------------------

  test "ensure_token does not override an existing token" do
    custom_token = "my-custom-token"

    invitation = SchoolInvitation.new(
      school: @school,
      email: "teacher@example.com",
      token: custom_token
    )

    invitation.valid?
    assert_equal custom_token, invitation.token
  end
end
