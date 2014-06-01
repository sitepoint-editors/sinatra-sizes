require_relative 'test_helper.rb'

def app
  Controller
end

class WebsiteTest < MiniTest::Unit::TestCase
  def test_it_can_encrypt_from_a_URL
    post '/', params={plaintext: 'hello', shift: '2'}
    assert last_response.ok?
    assert last_response.body.include?('hello'.caesar_shift(2))
  end
end
 
