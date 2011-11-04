require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  setup do
    @game = games(:one)
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, :id => @game.to_param
    assert_response :success
  end

  test "should handle get new" do
    get :new
    assert_redirected_to signin_path
  end
  
  test "valid user create game with others" do
    u = Factory(:user)
    fake_sign_in u
    o = Factory(:user)
    get :new, :opponent => o.name
    assert_template :new
  end
  
  test "invalid user should not create game" do
    post :create, :game => @game.attributes
    assert_redirected_to signin_path
  end
  
  test "valid user should create game" do
    user = Factory(:user)
    fake_sign_in user
    other = Factory(:user)
    assert_difference "Game.count", +1 do
      post :create, :game => {:mode => "1", :opponent => other.name, :sgf => "fake_sgf"} 
    end
  end
  
  test "valid user should not duel with self" do
    user = Factory(:user)
    fake_sign_in user
    assert_no_difference "Game.count" do
      post :create, :game => {:mode => "1", :opponent => user.name, :sgf => "fake_sgf"}
      assert_response 403
    end
  end
  
  test "admin should get edit" do
    fake_sign_in Factory(:user)
    get :edit, :id => @game.to_param
    assert_template 'edit'
  end

  test "invalid user should not get edit" do
    get :edit, :id => @game.to_param
    assert_redirected_to root_url
  end
  
  test "admin should be able to update game" do
    fake_sign_in Factory(:user)
    put :update, :id => @game.to_param, :game => @game.attributes
    assert_redirected_to @game
  end
  
  test "invalid user should not update game" do
    put :update, :id => @game.to_param, :game => @game.attributes
    assert_redirected_to root_url
  end
  
  test "should handle destroy game" do
    delete :destroy, :id => @game.to_param
    assert_redirected_to root_url
  end
  
  test "qualification before create game" do
    user = Factory(:user)
    user.level = 0
    user.save
    fake_sign_in user
    
    get :new, :opponent => users(:one).name
    assert_redirected_to challenge_url
  end
  
end
