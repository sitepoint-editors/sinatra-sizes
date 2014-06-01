require 'sinatra/base'
require_relative 'lib/caesar-cipher.rb'
require_relative 'helpers/helpers.rb'

class Controller < Sinatra::Base

  helpers TitleHelpers

  get '/' do
    erb :form
  end

  post '/' do
    @title = "Secret Message"
    @plaintext = params[:plaintext].chomp
    shift = params[:shift].to_i
    @ciphertext = @plaintext.caesar_shift(shift)
    erb :result
  end
end
