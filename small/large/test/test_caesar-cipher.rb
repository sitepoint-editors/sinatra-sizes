require_relative 'test_helper.rb'

class CaesarCipherTest < MiniTest::Unit::TestCase
  
  def test_it_can_encrypt_strings
    assert_equal 'JGNNQ','hello'.caesar_shift(2)
  end

  def test_it_can_encrypt_with_negative_shifts
    assert_equal 'GDKKN','hello'.caesar_shift(-1)
  end
end
