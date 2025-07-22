require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get not_found" do
    get errors_not_found_url
    assert_response :not_found  # 404
  end

  test "should get internal_server_error" do
    get errors_internal_server_error_url
    assert_response :internal_server_error  # 500
  end

  test "should get unprocessable_entity" do
    get errors_unprocessable_entity_url
    assert_response :unprocessable_entity  # 422
  end
end
