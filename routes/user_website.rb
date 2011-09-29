require 'error'
require 'util'
require 'logic/user'

module Route
	module UserWebsite

		get '/user/register' do
			#if session.key?("last_err")
			#	@last_err = session["last_err"]
			#	session.delete("last_err")
			#end

			erb :register
		end

		post '/user/register' do
			successful = false
			last_err = ""

			# Gets post parameters
			email = params["email"]
			password = params["password"]
				
			# Checks if email parameter exists
			if email.empty?
				last_err = "Please provide an email"
				session["last_err"] = last_err
				redirect '/user/register'
			end

			# Checks if password parameter exists
			if password.empty?
				last_err = "Please provide a password"
				session["last_err"] = last_err
				redirect '/user/register'
			end

			# Calls the logic function for user registration
			begin
				id = Logic::User.user_register(@conn, email, password)
				session["id"] = id.to_s	
				successful = true
			rescue ShiftError => boom
				last_err = boom.error.err_msg
				session["last_err"] = last_err
				redirect '/user/register'
			end

			if successful
				redirect '/dashboard'
			else
				last_err = "Something happend"
				session["last_err"] = last_err
				redirect '/user/register'
			end

		end

		post '/login' do
			authenticated = false

			# Gets post parameters
			email = params["email"]
			password = params["password"]
				
			# Checks if email parameter exists
			if email.empty?
				last_err = "Please provide an email"
				session["last_err"] = last_err
				redirect '/'
			end

			# Checks if password parameter exists
			if password.empty?
				last_err = "Please provide a password"
				session["last_err"] = last_err
				redirect '/'
			end

			authenticated, user = authorized_user?(email, password)

			if authenticated
				session["id"] = user["_id"].to_s
				redirect '/dashboard'
			else
				last_err = "Authentiation failed"
				session["last_err"] = last_err
				redirect '/'
			end

		end

		get '/logout' do
			session.clear()
			redirect '/'
		end

		get '/dashboard' do
			@id = session["id"]

			user = Logic::User.get_user(@conn, @id)
			@applications = Logic::User.list_applications(user)

			erb :dashboard
		end

		get '/application/create' do
			erb :create_application
		end

		post '/application/create' do
			successful = false

			user_id = session["id"]

			# Gets post parameters
			name = params["name"]
				
			# Checks if email parameter exists
			if name.empty?
				last_err = "Please provide an application name"
				session["last_err"] = last_err
				redirect '/application/create'
			end

			# Calls the logic function for create application
			begin
				app = Logic::User.create_application(@conn, user_id, name)

				successful = true
			rescue ShiftError => boom
				last_err = boom.error.err_msg
				session["last_err"] = last_err
				redirect '/application/create'
			end

			if successful
				redirect '/dashboard'
			else
				last_err = "Something bad happened"
				session["last_err"] = last_err
				redirect '/application/create'
			end

		end

	end
end
