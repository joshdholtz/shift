require 'sinatra'
require 'json'

require 'rubygems'
require 'mongo'
require 'bson'

require 'uuid'
require 'digest/md5'

require 'authorization'
require 'routes/test'
require 'routes/user'
require 'routes/application'

helpers do
	include Shift::Authorization
end

# Gets a connection from the Mongo connection pool
before do
	@conn = Mongo::Connection.new("localhost", 27017, :pool_size => 5, :timeout => 5)

end

include Route::Test
include Route::User
include Route::Application


