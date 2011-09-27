require 'error'
require 'util'
require 'logic/user'

module Route
	module User

		# Registers a user
		# Params:
		# * email
		# * password
		post '/user/register' do
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

			begin
				success = Logic::User.user_register(@conn, email, password)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			return Util.response(success, data)
		end

		# Creates an application under a user
		post '/applications/create' do
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

			authorized, user = required_user_authorization(params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_user_authentication)
			end

			id = user['_id']

			begin
				data = Logic::User.create_application(@conn, id, name)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)

		end

		get '/applications/list' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			authorized, user = required_user_authorization(params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_user_authentication)
			end

			begin
				data["applications"] = Logic::User.list_applications(user)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end

		get '/applications/find/:app_id' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets clean url parameters
			app_id = params[:app_id]

			authorized, user = required_user_authorization(params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_user_authentication)
			end

			begin
				data = Logic::User.find_application(@conn, user, app_id)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end
		
		post '/applications/update/:app_id' do
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

			authorized, user = required_user_authorization(params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_user_authentication)
			end

			begin
				data = Logic::User.update_application(@conn, user, app_id, name)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)

		end

		get '/applications/delete/:app_id' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets clean url parameters
			app_id = params[:app_id]

			authorized, user = required_user_authorization(params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_user_authentication)
			end

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
