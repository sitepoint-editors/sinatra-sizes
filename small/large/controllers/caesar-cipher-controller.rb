#$:.unshift(File.expand_path('../../lib', __FILE__))
#require 'caesar-cipher'

class CaesarCipherController < Controller
  get '/' do
    erb :form
  end

  post '/' do
    @plaintext = params[:plaintext].chomp
    shift = params[:shift].to_i
    @ciphertext = @plaintext.caesar_shift(shift)
    erb :result
  end
end
