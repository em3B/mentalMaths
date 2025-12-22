require "test_helper"

class SchoolInvitationsControllerTest < ActionDispatch::IntegrationTest
  test "show redirects to sign in when logged out" do
    school = School.create!(
      name: "Test School",
      stripe_customer_id: "cus_test_123",
      billing_status: "active",
      subscription_ends_at: 1.month.from_now,
      seat_limit: 10
    )

    invitation = SchoolInvitation.create!(
      school: school,
      email: "school@school.com",
      token: "invite-token-123",
      accepted_at: nil,
      expires_at: 1.week.from_now
    )

    get "/school_invitations/#{invitation.token}"

    assert_redirected_to new_user_session_path
    assert_equal invitation.token, session[:pending_school_invite_token]
  end
end
