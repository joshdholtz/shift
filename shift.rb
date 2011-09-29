require 'sinatra'
require 'json'

require 'rubygems'
require 'mongo'
require 'bson'

require 'uuid'
require 'digest/md5'

require 'authorization'
require 'routes/test'
require 'routes/website'
require 'routes/user_website'
require 'routes/application_website'
require 'routes/user_api'
require 'routes/application_api'

enable :sessions

helpers do
	include Shift::Authorization
end

# Gets a connection from the Mongo connection pool
before do
	@conn = Mongo::Connection.new("127.0.0.1", 27017, :pool_size => 5, :timeout => 5)

end

# Closes a connection from the Mongo connection pool
after do
	@conn.close
end

# Includes routes that are used for the website
include Route::Website
include Route::UserWebsite
include Route::ApplicationWebsite

# Includes routes that are used for the API
include Route::Test
include Route::UserAPI
include Route::ApplicationAPI


