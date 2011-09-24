require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  setup do
    @follower = Factory(:user)
    @followed = Factory(:user)
    @relationship = @follower.relationships.build(:followed_id => @followed.id)
  end
  
  test "should create a new instance given valid attributes" do
    @relationship.save!
  end
  
  test "follow methods" do
    @relationship.save
    assert_equal(@relationship.follower, @follower)
    assert_equal(@relationship.followed, @followed)
  end
  
  test "validation" do
    @relationship.follower_id = nil
    assert_equal(@relationship.valid?, false)
    @relationship.follower_id = Factory(:user).id
    assert_equal(@relationship.valid?, true)
    @relationship.followed_id = nil
    assert_equal(@relationship.valid?, false)
  end
end
