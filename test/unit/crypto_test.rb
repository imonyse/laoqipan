require 'test_helper'
require 'crypto'

class CryptoTest < ActiveSupport::TestCase
  test "encrypt should match decrypt result" do
    cipher = Crypto.encrypt("123abc--lalala")
    plain = Crypto.decrypt(cipher)
    assert_equal(plain, "123abc--lalala")
  end
end