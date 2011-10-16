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
		put '/api/user/register', :email => "joshdholtz@gmail.com", :password => "test1" 
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
		post '/api/app', :name => "App1"
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']

		# List applications
		header('token',  token)
		get '/api/app'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['applications']
		assert_equal response['data']['applications'].length, 1
		assert_not_nil response['data']['applications'][0]['app_id']
		assert_equal response['data']['applications'][0]['name'], "App1"
		app_id = response['data']['applications'][0]['app_id']

		# Find application
		header('token',  token)
		get '/api/app/' + app_id
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_equal response['data']['app_id'], app_id
		assert_equal response['data']['name'], "App1"
		assert_not_nil response['data']['pass_key']
		pass_key = response['data']['pass_key']

		# Update application
		header('token',  token)
		put '/api/app/' + app_id, :name => "App2"
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_equal response['data']['app_id'], app_id
		assert_equal response['data']['name'], "App2"
		assert_not_nil response['data']['pass_key']

		# Application login
		authorize app_id, pass_key
		post '/api/app/login'
		puts last_response.body
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['token']
		app_token = response['data']['token']

		# Insert document
		header('token', app_token)
		post '/api/doc/contacts', :document => JSON.generate( {"first_name" => "Josh", "last_name" => "Holtz", "age" => 22} )
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_equal response['data']['first_name'], "Josh"
		assert_equal response['data']['last_name'], "Holtz"
		assert_equal response['data']['age'], 22

		# Query document
		header('token', app_token)
		get '/api/doc/contacts'
		puts last_response.body
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
		put '/api/doc/contacts', :document => JSON.generate( {"_id" => doc_id, "first_name" => "Josh", "last_name" => "Holtz", "age" => 23} )
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_equal response['data']['first_name'], "Josh"
		assert_equal response['data']['last_name'], "Holtz"
		assert_equal response['data']['age'], 23

		# Delete document
		header('token', app_token)
		delete '/api/doc/contacts/' + URI.escape( JSON.generate( {"_id" => doc_id } ) )
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']

		# Query document - after deletion
		header('token', app_token)
		get '/api/doc/contacts'
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']
		assert_not_nil response['data']['documents']
		assert_equal response['data']['documents'].length, 0

		# Application logout
		header('token', app_token)	
		post '/api/app/logout'
		puts last_response.body
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true

		# Delete application
		header('token', token)
		delete '/api/app/' + app_id
		response = JSON.parse(last_response.body)
		assert_equal response['success'], true, response['err_msg']

		# List applications - verify delete
		header('token',  token)
		get '/api/app'
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
