require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @attr = {
      :name => "kiki",
      :email => "kiki@example.com",
      :password => "foobar",
      :password_confirmation  => "foobar",
    }
  end
  
  test "should respond to show" do
    get :show, :id => users(:one).to_param
    assert_response :success, @response.body
  end
  
  test "should respond to index" do
    fake_sign_in Factory(:user)
    get :index
    assert_response :success, @response.body
  end
  
  test "guest should redirect to root for index page" do
    get :index
    assert_redirected_to signin_url
  end
  
  test "new action should render new template" do
    get :new
    assert_template(:new)
  end
  
  test "create action should render new template when model is invalid" do
    post :create, @attr.merge(:name => "")
    assert_template(:new)
  end
  
  test "create action should redirect when model is valid" do
    post :create, :user => @attr
    assert_redirected_to user_path(assigns(:user))
  end
  
  test "edit action should redirect to signin when not logged in" do
    get :edit, :id => "ignored"
    assert_redirected_to signin_url
  end
  
  test "edit action should render edit template when logged in" do
    @user = Factory(:user)
    fake_sign_in(@user)
    get :edit, :id => @user.id
    assert_template(:edit)
  end
  
  test "update action should redirect when not logged in" do
    put :update, :id => users(:one).to_param, :user => @attr
    assert_redirected_to signin_url
  end
  
  test "update action should render edit template when user is invalid" do
    @user = users(:one)
    fake_sign_in(@user)
    put :update, :id => @user.to_param, :user => @attr.merge(:name => "")
    assert_template(:edit)
  end
  
  test "update action should redirect when user is valid" do
    @user = users(:one)
    fake_sign_in(@user)
    put :update, :id => @user.to_param, :user => @attr
    assert_redirected_to user_path(@user)
  end
  
  test "login user follower/following count" do
    @user = Factory(:user)
    fake_sign_in @user
    other_user = Factory(:user)
    other_user.follow! @user
    
    get :show, :id => @user.id
    assert_select '#follower', :text => '1'
    assert_select '#following', :text => '0'
  end
  
  test "guest follower/following protect" do
    get :following, :id => 1
    assert_redirected_to signin_url
    
    get :followers, :id => 1
    assert_redirected_to signin_url
  end
  
  test "login user should see follower/following count page" do
    @me = Factory(:user)
    fake_sign_in @me
    @another = Factory(:user)
    get :following, :id => @me.id
    assert_response :success
    get :followers, :id => @me.id
    assert_response :success
    
    get :following, :id => @another.id
    assert_response :success
    get :followers, :id => @another.id
    assert_response :success
  end
end
