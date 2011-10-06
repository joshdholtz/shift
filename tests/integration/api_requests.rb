require 'shift.rb'
require 'test/unit'
require 'rack/test'
require 'json'

class GoodRequestTest < Test::Unit::TestCase
	include Rack::Test::Methods

	def app
		Sinatra::Application
	end

	def setup
		authorize "admin", "admin"
		get '/api/test/clean'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true
	end 
	
	def test_good_requests
		# Register
		post '/api/user/register', :email => "joshdholtz@gmail.com", :password => "test1" 
		response = JSON.parse(last_response.body)

		assert_equal response['success'], true, response['err_msg']

		# Login
		authorize "joshdholtz@gmail.com", "test1"
		post '/api/user/login'
		response = JSON.parse(last_response.body)

		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['token'], response['err_msg']
		token = response['data']['token']

		# Create application
		header('token',  token)
		post '/api/applications/create', :name => "App1"
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']

		# List applications
		header('token',  token)
		get '/api/applications/list'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['applications']
		assert_equal response['data']['applications'].length, 1
		assert_not_nil response['data']['applications'][0]['app_id']
		assert_equal response['data']['applications'][0]['name'], "App1"
		app_id = response['data']['applications'][0]['app_id']

		# Find application
		header('token',  token)
		get '/api/applications/find/' + app_id
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_equal response['data']['app_id'], app_id
		assert_equal response['data']['name'], "App1"
		assert_not_nil response['data']['access_key']
		assert_not_nil response['data']['secret_key']
		access_key = response['data']['access_key']
		secret_key = response['data']['secret_key']

		# Update application
		header('token',  token)
		post '/api/applications/update/' + app_id, :name => "App2"
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_equal response['data']['app_id'], app_id
		assert_equal response['data']['name'], "App2"
		assert_not_nil response['data']['access_key']
		assert_not_nil response['data']['secret_key']

		# Application login
		authorize access_key, secret_key
		post '/api/application/login', :app_id => app_id
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['token']
		app_token = response['data']['token']

		# Insert document
		header('token', app_token)
		post '/api/document/insert', :app_id => app_id, :collection => "contacts", :data => JSON.generate( {"first_name" => "Josh", "last_name" => "Holtz", "age" => 22} )
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']

		# List collections
		header('token', app_token)
		get '/api/collection/list/' + app_id
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['collections']
		assert_equal response['data']['collections'].length, 1
		assert_equal response['data']['collections'][0], "contacts"

		# Rename collection
		header('token', app_token)
		post '/api/collections/update', :app_id => app_id, :collection => "contacts", :new_name => "friends"
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']

		# List collections
		header('token', app_token)
		get '/api/collection/list/' + app_id
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['collections']
		assert_equal response['data']['collections'].length, 1
		assert_equal response['data']['collections'][0], "friends"

		# Query document
		header('token', app_token)
		get '/api/documents/query/' + app_id + '/friends'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['documents']
		assert_equal response['data']['documents'].length, 1
		assert_not_nil response['data']['documents'][0]['_id']
		assert_equal response['data']['documents'][0]['first_name'], "Josh"
		assert_equal response['data']['documents'][0]['last_name'], "Holtz"
		assert_equal response['data']['documents'][0]['age'], 22
		doc_id = response['data']['documents'][0]['_id']

		# Update document
		header('token', app_token)
		post '/api/document/update', :app_id => app_id, :collection => "friends", :data => JSON.generate( {"_id" => doc_id, "first_name" => "Josh", "last_name" => "Holtz", "age" => 23} )
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_equal response['data']['first_name'], "Josh"
		assert_equal response['data']['last_name'], "Holtz"
		assert_equal response['data']['age'], 23

		# Delete document
		header('token', app_token)
		get '/api/documents/delete/' + app_id + '/friends/' + URI.escape( JSON.generate( {"_id" => doc_id } ) )
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']

		# Query document - after deletion
		header('token', app_token)
		get '/api/documents/query/' + app_id + '/friends'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['documents']
		assert_equal response['data']['documents'].length, 0

		# Delete collection
		header('token', app_token)
		get '/api/collections/delete/' + app_id + '/friends'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']

		# List collection - after deletion
		header('token', app_token)
		get '/api/collection/list/' + app_id
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['collections']
		assert_equal response['data']['collections'].length, 0

		# Application logout
		header('token', app_token)	
		post '/api/application/logout'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true

		# Delete application
		header('token', token)
		get '/api/applications/delete/' + app_id
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']

		# List applications - verify delete
		header('token',  token)
		get '/api/applications/list'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['applications']
		assert_equal response['data']['applications'].length, 0

		# User logout
		header('token',  token)
		post '/api/user/logout'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
	end

end
