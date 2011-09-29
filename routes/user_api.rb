require 'error'
require 'util'
require 'logic/user'

module Route
	module UserAPI

		# Registers a user
		# Url:
		# Params:
		# * email
		# * password
		post '/api/user/register' do
			# I want to implement something like this for all other API calls so that each
			# API call has its own self documentation
			if params.key?("help")
				description = "This function registers a developer to use Shift"
				parameters = "email, password"
				response = ""

				rtn = description + "<br/>" + parameters + "<br/>" + response

				return [200, rtn]
			end

			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets post parameters
			email = params["email"]
			password = params["password"]
				
			# Checks if email parameter exists
			if email == nil
				return Util.error_response(ShiftErrors.e00100_email_is_required)
			end

			# Checks if password parameter exists
			if password == nil
				return Util.error_response(ShiftErrors.e00101_password_is_required)
			end

			# Calls the logic function for user registration
			begin
				user_id = Logic::User.user_register(@conn, email, password)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end

		# Logs in a user
		# Url:
		# Params:
		post '/api/user/login' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Verifies the user is authorized for this route and returns the user object
			authorized, user = required_user_authorization(params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_user_authentication)
			end

			# Authenticates
			db = @conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'user_sessions' collection
			db = @conn.db("shift")
			col = db.collection("user_sessions")

			# Generates token and inserts it into the session collection
			token = UUID.new.generate
			col.insert( {"_id" => token, "user_id" => user["_id"] } )

			success = true
			data["token"] = token
			return Util.response(success, data)

		end

		# Logs out a user
		# Url:
		# Params:
		post '/api/user/logout' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}
				
			# Verifies the user is authorized for this route and returns the user object
			authorized, user = valid_user_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00005_invalid_user_token)
			end

			# Gets token from header
			token = env["HTTP_TOKEN"]

			# Authenticates
			db = @conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'user_sessions' collection
			db = @conn.db("shift")
			col = db.collection("user_sessions")

			# Removes token from the session collection
			col.remove( {"_id" => token} )

			success = true
			return Util.response(success, data)

		end

		# Creates an application under a user
		# Url:
		# Params:
		# * name
		post '/api/applications/create' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets post parameters
			name = params["name"]
				
			# Checks if name parameter exists
			if name  == nil or name.empty?
				return Util.error_response(ShiftErrors.e00200_name_is_required)
			end

			# Verifies the user is authorized for this route and returns the user object
			authorized, user = valid_user_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00005_invalid_user_token)
			end

			id = user['_id']

			# Calls the logic function for create application
			begin
				data = Logic::User.create_application(@conn, id, name)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)

		end

		# Lists applications under a user
		# Url:
		# Params:
		get '/api/applications/list' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Verifies the user is authorized for this route and returns the user object
			authorized, user = valid_user_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00005_invalid_user_token)
			end

			# Calls the logic function for list applications
			begin
				data["applications"] = Logic::User.list_applications(user)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end

		# Finds an application under a user
		# Url:
		# * app_id
		# Params:
		get '/api/applications/find/:app_id' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets clean url parameters
			app_id = params[:app_id]

			# Verifies the user is authorized for this route and returns the user object
			authorized, user = valid_user_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00005_invalid_user_token)
			end

			# Calls the logic function for find application
			begin
				data = Logic::User.find_application(@conn, user, app_id)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end
		
		# Updates an application under a user
		# Url:
		# * app_id
		# Params:
		# * name
		post '/api/applications/update/:app_id' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets clean url parameters
			app_id = params[:app_id]

			# Gets post parameters
			name = params["name"]
				
			# Checks if name parameter exists
			if name  == nil or name.empty?
				return Util.error_response(ShiftErrors.e00300_name_is_required)
			end

			# Verifies the user is authorized for this route and returns the user object
			authorized, user = valid_user_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00005_invalid_user_token)
			end

			# Calls the logic function for update application
			begin
				data = Logic::User.update_application(@conn, user, app_id, name)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)

		end

		# Deletes an application under a user
		# Url:
		# * app_id
		# Params:
		get '/api/applications/delete/:app_id' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets clean url parameters
			app_id = params[:app_id]

			# Verifies the user is authorized for this route and returns the user object
			authorized, user = valid_user_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00005_invalid_user_token)
			end

			# Calls the logic function for delete application
			begin
				success = Logic::User.delete_application(@conn, user, app_id)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)

		end

	end
end
