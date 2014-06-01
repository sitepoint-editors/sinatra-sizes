$:.unshift(File.expand_path('../../lib', __FILE__))

require 'sinatra/base'

class Controller < Sinatra::Base
  helpers Helpers

  set :views, File.expand_path('../../views', __FILE__)
end
