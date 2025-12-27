require "application_system_test_case"

class FamilyAddsChildTest < ApplicationSystemTestCase
  setup do
    @family = User.create!(
      email: "family-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "family_#{SecureRandom.hex(4)}",
      role: "family"
    )
  end

  test "family can create a child account from the family dashboard" do
    visit new_user_session_path

    select "Family", from: "Role"
    fill_in "Username or Email", with: @family.email

    # Disambiguate login password field
    find('input[name="user[password]"]').set("Password123!")
    click_button "Log in"

    assert_current_path family_dashboard_path

    child_username = "child_#{SecureRandom.hex(3)}"

    fill_in "Child’s Username", with: child_username

    # Disambiguate child form password fields (they have the same label text)
    find('input[name="user[password]"]').set("Password123!")
    find('input[name="user[password_confirmation]"]').set("Password123!")

    click_button "Create Child"

    assert_text "Child created successfully."
    assert_text "Your Children"
    assert_text child_username
  end
end
