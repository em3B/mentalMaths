require "test_helper"

class SchoolInvitationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers if defined?(Devise::Test::IntegrationHelpers)

  setup do
    @school = School.create!(
      name: "Test School",
      contact_email: "contact@email.com",
      stripe_customer_id: "cus_test_123",
      billing_status: "active",
      subscription_ends_at: 1.month.from_now,
      seat_limit: 10
    )

    @invitation = SchoolInvitation.create!(
      school: @school,
      email: "school@school.com",
      token: "invite-token-123",
      accepted_at: nil,
      expires_at: 1.week.from_now
    )
  end

  # ---- SHOW -----------------------------------------------------------------

  test "show redirects to sign in when logged out (stores pending token)" do
    get school_invitation_path(@invitation.token)

    assert_redirected_to new_user_session_path
    assert_equal @invitation.token, session[:pending_school_invite_token]
    assert_equal "Please sign in to accept the invitation.", flash[:alert]
  end

  test "show redirects to root when invitation already used" do
    @invitation.update!(accepted_at: 1.day.ago)

    get school_invitation_path(@invitation.token)

    assert_redirected_to root_path
    assert_equal "That invitation has already been used.", flash[:alert]
  end

  test "show redirects to root when invitation expired" do
    @invitation.update!(expires_at: 1.day.ago)

    get school_invitation_path(@invitation.token)

    assert_redirected_to root_path
    assert_equal "That invitation has expired.", flash[:alert]
  end

  test "show renders successfully when logged in and invitation valid" do
    teacher = create_teacher_user!
    sign_in teacher

    get school_invitation_path(@invitation.token)

    # Assumes show renders a page. If you don't have a template, this will fail with MissingTemplate.
    assert_response :success
  end

  # ---- ACCEPT ---------------------------------------------------------------

  test "accept redirects to sign in when logged out (stores pending token)" do
    post accept_school_invitation_path(@invitation.token)

    assert_redirected_to new_user_session_path
    assert_equal @invitation.token, session[:pending_school_invite_token]
    assert_equal "Please sign in to accept the invitation.", flash[:alert]
  end

  test "accept redirects to root when school's subscription is not active" do
    teacher = create_teacher_user!
    sign_in teacher

    @school.update!(billing_status: "inactive")

    post accept_school_invitation_path(@invitation.token)

    assert_redirected_to root_path
    assert_equal "This school's subscription is not active.", flash[:alert]
  end

  test "accept redirects to root when school has no available seats" do
    teacher = create_teacher_user!
    sign_in teacher

    # Fill the seats (assumes seats_available? depends on seat_limit vs members count)
    @school.update!(seat_limit: 0)

    post accept_school_invitation_path(@invitation.token)

    assert_redirected_to root_path
    assert_equal "This school has no available seats.", flash[:alert]
  end

  test "accept redirects to root when current user is not a teacher" do
    family_user = create_family_user!
    sign_in family_user

    post accept_school_invitation_path(@invitation.token)

    assert_redirected_to root_path
    assert_equal "Only teacher accounts can join a school plan.", flash[:alert]
  end

  test "accept happy path joins school and marks invitation accepted" do
    teacher = create_teacher_user!
    sign_in teacher

    post accept_school_invitation_path(@invitation.token)

    assert_redirected_to teacher_dashboard_path
    assert_equal "You’ve joined #{@school.name}.", flash[:notice]

    teacher.reload
    @invitation.reload

    assert_equal @school.id, teacher.school_id
    assert_not_nil @invitation.accepted_at
  end

  private

  # These helpers avoid factories. If you already use factories/fixtures, replace with those.
  #
  # If your User model validates extra fields (first_name/last_name/username),
  # add them here to satisfy validations.
  def create_teacher_user!
    User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      role: "teacher",
      username: "teacher_#{SecureRandom.hex(4)}"
    )
  end

  def create_family_user!
    User.create!(
      email: "family-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      role: "family",
      username: "family_#{SecureRandom.hex(4)}"
    )
  end
end
