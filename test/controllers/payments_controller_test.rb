require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get payments_edit_url
    assert_response :success
  end

  test "should get update" do
    get payments_update_url
    assert_response :success
  end
end
