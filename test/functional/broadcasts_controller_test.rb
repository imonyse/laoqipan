require 'test_helper'

class BroadcastsControllerTest < ActionController::TestCase
  test "everyone should view index" do
    get :index
    assert_response :success
  end
  
  test "everyone should view show" do
    get :show, :id => Factory(:broadcast).id
    assert_response :success
    assert_template 'show'
  end
  
  test "non-admin user should not get new" do
    get :new
    assert_redirected_to broadcasts_url
  end
  
  test "admin user can get new" do
    fake_sign_in Factory(:user)
    get :new
    assert_template 'new'
  end
  
  test "non-admin user should not create broadcast" do
    broadcast = Factory(:broadcast)
    
    assert_no_difference "Broadcast.count" do
      post :create, :broadcast => broadcast.attributes
    end
    assert_redirected_to broadcasts_url
  end
  
  test "admin should be able to create broadcast" do
    fake_sign_in Factory(:user)
    broadcast = Factory(:broadcast)
    
    assert_difference "Broadcast.count", +1 do
      post :create, :broadcast => broadcast.attributes
    end
    
    assert_redirected_to broadcast_url(assigns(:broadcast))
  end
  
  test "non-admin use should not get edit" do
    get :edit, :id => Factory(:broadcast)
    assert_redirected_to broadcasts_url
  end
  
  test "admin should get edit" do
    fake_sign_in Factory(:user)
    get :edit, :id => Factory(:broadcast)
    assert_template 'edit'
  end
  
  test "non-admin user should not post update" do
    broadcast = Factory(:broadcast)
    post :update, :id => broadcast.id, :broadcast => broadcast.attributes
    assert_redirected_to broadcasts_url
  end
  
  test "admin should post update" do
    broadcast = Factory(:broadcast)
    fake_sign_in Factory(:user)
    post :update, :id => broadcast.id, :broadcast => broadcast.attributes
    assert_redirected_to broadcast
  end
  
  test "non-admin should not destroy" do
    broadcast = Factory(:broadcast)
    assert_no_difference "Broadcast.count" do
      delete :destroy, :id => broadcast.id
    end
    assert_redirected_to broadcasts_url
  end
  
  test "admin should destroy" do
    fake_sign_in Factory(:user)
    broadcast = Factory(:broadcast)
    assert_difference "Broadcast.count", -1 do
      delete :destroy, :id => broadcast.id
    end
    assert_redirected_to broadcasts_url
  end
end
