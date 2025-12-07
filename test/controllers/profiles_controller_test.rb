require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "teacher@example.com",
      password: "password123",
      role: "teacher",
      username: "test"
    )

    sign_in @user
  end

  test "should get show" do
    get profile_path   # <- changed
    assert_response :success
  end

  test "should get edit" do
    get edit_profile_path  # <- changed
    assert_response :success
  end

  test "should update profile" do
    patch profile_path, params: { user: { name: "New Name", email: "new@example.com" } }  # <- changed
    assert_redirected_to profile_path
    @user.reload
    assert_equal "New Name", @user.name
    assert_equal "new@example.com", @user.email
  end
end
