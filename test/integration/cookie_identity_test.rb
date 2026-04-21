require "test_helper"

class CookieIdentityTest < ActionDispatch::IntegrationTest
  test "sets user_token cookie on first visit" do
    get "/scheduler"
    assert_not_nil cookies[:user_token]
    assert cookies[:user_token].length >= 10
  end

  test "same cookie is reused on subsequent requests" do
    get "/scheduler"
    first_token = cookies[:user_token]
    get "/scheduler"
    assert_equal first_token, cookies[:user_token]
  end

  test "cookie is httponly and samesite lax" do
    get "/scheduler"
    cookie_header = response.headers["Set-Cookie"]
    assert_includes cookie_header.downcase, "httponly"
    assert_includes cookie_header.downcase, "samesite=lax"
  end
end
