require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @attr = {
      :name => "cas",
      :email => "cas@example.com",
      :password => "foobar", 
      :password_confirmation => "foobar"
      }
  end
  
  test "fixture validation" do
    @user = users(:one)
    assert(@user != nil, "user one is invalid")
    @user = users(:two)
    assert(@user != nil, "user two is invalid")
  end
  
  test "user should have a name" do
    @user = User.new(@attr.merge(:name => ''))
    assert(!@user.valid?, "no name user is valid")
  end
  
  test "user should have an well formed email" do
    @user = User.new(@attr.merge(:email => "s@s@.com"))
    assert(!@user.valid?, "ill formed user is valid")
  end
  
  test "user should have an unique email" do
    @user = User.new(@attr.merge(:email => "foo@example.com"))
    assert(!@user.valid?, "duplicated email user is valid")
  end
  
  test "user should have an unique name" do
    @user = User.new(@attr.merge(:name => "foo"))
    assert(!@user.valid?, "duplicated name user is valid")
  end
  
  test "should validate password is longer than 5 characters" do
    @user = User.new(@attr.merge(:password => "fff", :password_confirmation => "fff"))
    assert(!@user.valid?, "short password user is valid")
  end
  
  test "should have matching password confirmation" do
    @user = User.new(@attr.merge(:password_confirmation => "llala"))
    assert(!@user.valid?, "unmatching password confirmation user is valid")
  end
  
  test "should authenticate by email" do
    @user = User.create(@attr)
    assert_equal(User.authenticate(@attr[:email], @attr[:password]), @user)
  end
  
  test "should ignore case and authenticate by email " do
    @user = User.create(@attr)
    assert_equal(User.authenticate(@attr[:email].upcase, @attr[:password]), @user)
  end
  
  test "should authenticate by name" do
    @user = User.create(@attr)
    assert_equal(User.authenticate(@attr[:name], @attr[:password]), @user)
  end
  
  test "should ignore case and authenticate by name" do
    @user = User.create(@attr)
    assert_equal(User.authenticate(@attr[:name].upcase, @attr[:password]), @user)
  end
  
  test "should not authenticate by not registered email" do
    User.create(@attr)
    assert(!User.authenticate("g@c.cn", "foobar"), "not registered email authenticated")
  end
  
  test "should not authenticate bad user name" do
    User.create(@attr)
    assert(!User.authenticate("non", "foobar"), "non-existing user authenticated")
  end
  
  test "should not authenticate wrong password" do
    User.create(@attr)
    assert(!User.authenticate(@attr[:name], "wrong"), "wrong password authenticated")
  end
  
  test "should have a win rate" do
    @user = users(:one)
    assert_equal(@user.win_rate, 0.43)
  end
end
