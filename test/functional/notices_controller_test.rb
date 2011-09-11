require 'test_helper'

class NoticesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "admin user should be able to view new" do
    fake_sign_in(Factory(:user))
    get :new, :format => :js
    assert_template(:new)
  end
  
  test "non-admin user should not view new " do
    fake_sign_in users(:one)
    get :new, :format => :js
    assert_response 401
  end
  
  test "guest user should not view new" do
    get :new, :format => :js
    assert_response 401
  end
end
