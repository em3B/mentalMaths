require "test_helper"

class SchoolInvitationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get school_invitations_show_url
    assert_response :success
  end
end
