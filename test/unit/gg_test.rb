require 'test_helper'
require 'gg'

class GGTest < ActiveSupport::TestCase
  test "convert move should work well" do
    assert_equal("cs", convert_move("C1"))
    assert_equal("pass", convert_move("PASS"))
    assert_equal("resign", convert_move("resign"))
    assert_equal("aj", convert_move("A10"))
    assert_equal("ad", convert_move("A16"))
    assert_equal("pd", convert_move("Q16"))
  end
end