require "test_helper"

class SchoolsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @teacher = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher",
      school_admin: false
    )

    @other_teacher = User.create!(
      email: "teacher2-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher2_#{SecureRandom.hex(4)}",
      role: "teacher",
      school_admin: false
    )

    @school = School.create!(
      name: "Test School",
      address: "1 Test Street",
      contact_email: "contact@test-school.example",
      stripe_customer_id: "cus_test_123",
      billing_status: "active",
      subscription_ends_at: 1.month.from_now,
      seat_limit: 10
    )

    @school_admin = User.create!(
      email: "admin-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "admin_#{SecureRandom.hex(4)}",
      role: "teacher",
      school: @school,
      school_admin: true
    )

    @school_member_not_admin = User.create!(
      email: "member-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "member_#{SecureRandom.hex(4)}",
      role: "teacher",
      school: @school,
      school_admin: false
    )
  end

  # ---- NEW ------------------------------------------------------------------

  test "new requires authentication" do
    get new_school_path
    assert_redirected_to new_user_session_path
  end

  test "new renders for signed-in user" do
    sign_in @teacher
    get new_school_path
    assert_response :success
  end

  # ---- START (no auth required) --------------------------------------------

  test "start sets session flag and redirects to sign in when logged out" do
    get school_subscriptions_path
    assert_equal true, session[:school_onboarding]
    assert_redirected_to new_user_session_path
  end

  test "start sets session flag and redirects to new school when logged in" do
    sign_in @teacher
    get school_subscriptions_path
    assert_equal true, session[:school_onboarding]
    assert_redirected_to new_school_path
  end

  # ---- CREATE ---------------------------------------------------------------

  test "create requires authentication" do
    post schools_path, params: { school: { name: "X", address: "Y", contact_email: "a@b.com" } }
    assert_redirected_to new_user_session_path
  end

  test "create creates school, assigns current_user to school, sets school_admin true, redirects to billing" do
    sign_in @teacher

    assert_difference("School.count", +1) do
      post schools_path, params: {
        school: {
          name: "New School",
          address: "123 Road",
          contact_email: "billing@newschool.example"
        }
      }
    end

    school = School.order(:id).last
    assert_redirected_to billing_school_path(school)

    @teacher.reload
    assert_equal school.id, @teacher.school_id
    assert_equal true, @teacher.school_admin
  end

  test "create re-renders new with 422 when invalid" do
    sign_in @teacher

    assert_no_difference("School.count") do
      post schools_path, params: {
        school: { name: "", address: "", contact_email: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  # ---- BILLING / MEMBERS (authz) -------------------------------------------

  test "billing requires authentication" do
    get billing_school_path(@school)
    assert_redirected_to new_user_session_path
  end

  test "billing denies non-admin even if in same school" do
    sign_in @school_member_not_admin
    get billing_school_path(@school)

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "billing denies admin from another school" do
    other_school = School.create!(name: "Other", address: "Z", contact_email: "o@o.example")
    other_admin = User.create!(
      email: "other-admin-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "other_admin_#{SecureRandom.hex(4)}",
      role: "teacher",
      school: other_school,
      school_admin: true
    )

    sign_in other_admin
    get billing_school_path(@school)

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "billing renders for school admin" do
    sign_in @school_admin
    get billing_school_path(@school)
    assert_response :success
  end

  test "members renders for school admin" do
    sign_in @school_admin
    get members_school_path(@school)
    assert_response :success
  end

  # ---- INVITE TEACHER -------------------------------------------------------

  test "invite_teacher requires authentication" do
    post invite_teacher_school_path(@school), params: { email: "invitee@example.com" }
    assert_redirected_to new_user_session_path
  end

  test "invite_teacher denies non-admin" do
    sign_in @school_member_not_admin

    assert_no_difference("SchoolInvitation.count") do
      post invite_teacher_school_path(@school), params: { email: "invitee@example.com" }
    end

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "invite_teacher creates invitation for admin and renders members" do
    sign_in @school_admin

    assert_difference("SchoolInvitation.count", +1) do
      post invite_teacher_school_path(@school), params: { email: "INVITEE@Example.com " }
    end

    assert_response :success

    invitation = SchoolInvitation.order(:id).last
    assert_equal @school.id, invitation.school_id
    assert_equal "invitee@example.com", invitation.email
    assert invitation.expires_at.present?
  end
end
