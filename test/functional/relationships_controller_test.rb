require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase
  test "should require signin for create" do
    post :create
    assert_redirected_to signin_url
  end
  
  test "should require signin for destroy" do
    delete :destroy, :id => 1
    assert_redirected_to signin_url
  end
  
  test "login user should create relationship" do
    @user = Factory(:user)
    @followed = Factory(:user)
    fake_sign_in @user
    assert_difference "Relationship.count", +1 do
      xhr :post, :create, :relationship => { :followed_id => @followed }
    end
  end
  
  test "login user should destroy relationship" do
    @user = Factory(:user)
    @followed = Factory(:user)
    @user.follow!(@followed)
    @relationship = @user.relationships.find_by_followed_id(@followed)
    fake_sign_in @user
    assert_difference "Relationship.count", -1 do
      xhr :delete, :destroy, :id => @relationship
    end
  end
end
