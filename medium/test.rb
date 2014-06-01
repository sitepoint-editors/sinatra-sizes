ENV['RACK_ENV'] = 'test'

require_relative 'main.rb'

require 'test/unit'
require 'rack/test'

class CaesarCipherTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
    def test_it_can_encrypt_strings
      assert_equal 'JGNNQ','hello'.caesar_shift(2)
    end

    def test_it_can_encrypt_with_negative_shifts
      assert_equal 'GDKKN','hello'.caesar_shift(-1)
    end

    def test_it_can_encrypt_from_a_URL
      post '/', params={plaintext: 'hello', shift: '2'}
      assert last_response.ok?
      assert last_response.body.include?('hello'.caesar_shift(2))
    end

end
