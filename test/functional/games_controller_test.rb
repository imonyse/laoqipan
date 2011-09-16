require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  setup do
    @game = games(:one)
  end
  
  test "should get index" do
    get :index, :format => :js
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
  
  test "when sign in, new should not choose self as opponent" do
    fake_sign_in users(:one)
    get :new, :opponent => users(:one).name, :format => :js
  end
  
  test "invalid user should not create game" do
    post :create, :game => @game.attributes
    assert_redirected_to signin_path
  end
  
  test "valid user should create game" do
    fake_sign_in users(:one)
    assert_difference "Game.count", +1 do
      post :create, :game => {:mode => "1", :opponent => users(:two).name, :sgf => "fake_sgf"} 
    end
  end
  
  test "valid user should not duel with self" do
    fake_sign_in users(:one)
    assert_no_difference "Game.count" do
      post :create, :game => {:mode => "1", :opponent => users(:one).name, :sgf => "fake_sgf"}
      assert_response 403
    end
  end

  test "should handle get edit" do
    get :edit, :id => @game.to_param
    assert_redirected_to root_url
  end
  
  test "should handle update game" do
    put :update, :id => @game.to_param, :game => @game.attributes
    assert_redirected_to root_url
  end
  
  test "should hanlde destroy game" do
    delete :destroy, :id => @game.to_param
    assert_redirected_to root_url
  end
end
