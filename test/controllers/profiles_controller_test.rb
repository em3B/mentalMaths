require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  TEST_PASSWORD = "correct-horse-battery-staple-42"

  setup do
    @teacher = confirm_for_devise!(User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      role: "teacher",
      username: "teacher_#{SecureRandom.hex(4)}"
    ))

    @family = confirm_for_devise!(User.create!(
      email: "family-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      role: "family",
      username: "family_#{SecureRandom.hex(4)}"
    ))

    @student = confirm_for_devise!(User.create!(
      email: "student-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      role: "student",
      username: "student_#{SecureRandom.hex(4)}"
    ))
  end

  def confirm_for_devise!(user)
    user.update!(confirmed_at: Time.current) if user.class.column_names.include?("confirmed_at")
    user.update!(locked_at: nil)            if user.class.column_names.include?("locked_at")
    user
  end

  # ---- AUTH / AUTHZ ---------------------------------------------------------

  test "redirects to sign in when logged out" do
    get profile_path
    assert_redirected_to new_user_session_path
  end

  test "student is blocked from profile show" do
    sign_in @student
    get profile_path

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "student is blocked from profile edit" do
    sign_in @student
    get edit_profile_path

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  test "student is blocked from profile update" do
    sign_in @student
    patch profile_path, params: { user: { name: "Nope" } }

    assert_redirected_to root_path
    assert_equal "Access denied.", flash[:alert]
  end

  # ---- SHOW / EDIT ----------------------------------------------------------

  test "teacher can view profile show" do
    sign_in @teacher
    get profile_path
    assert_response :success
  end

  test "family can view profile show" do
    sign_in @family
    get profile_path
    assert_response :success
  end

  test "teacher can view profile edit" do
    sign_in @teacher
    get edit_profile_path
    assert_response :success
  end

  # ---- UPDATE ---------------------------------------------------------------

  test "teacher can update profile (name + email)" do
    sign_in @teacher

    old_email = @teacher.email
    new_email = "new-#{SecureRandom.hex(4)}@example.com"

    patch profile_path, params: {
      user: {
        name: "New Name",
        email: new_email
      }
    }

    assert_redirected_to profile_path
    assert_equal "Profile updated successfully.", flash[:notice]

    @teacher.reload
    assert_equal "New Name", @teacher.name

    if @teacher.class.column_names.include?("unconfirmed_email")
      # reconfirmable behavior: email doesn't change immediately
      assert_equal old_email, @teacher.email
      assert_equal new_email, @teacher.unconfirmed_email
    else
      # non-confirmable behavior: email changes immediately
      assert_equal new_email, @teacher.email
    end
  end

  test "update failure re-renders edit when email is already taken" do
    taken = confirm_for_devise!(User.create!(
      email: "taken-#{SecureRandom.hex(4)}@example.com",
      password: TEST_PASSWORD,
      password_confirmation: TEST_PASSWORD,
      role: "teacher",
      username: "taken_#{SecureRandom.hex(4)}"
    ))

    sign_in @teacher

    patch profile_path, params: { user: { email: taken.email } }

    # Should render :edit (200), not redirect
    assert_response :success
    assert_nil flash[:notice]
  end
end
