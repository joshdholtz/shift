module Route
	module Test

		# This is just a test to play around with features
		get '/api/test' do
			if params.key?("help")
				description="This is just a method to help test"
				return [200, description]
			end

			authorized, user = required_user_authorization(params.key?("debug"))

			data = {"autorized" => authorized, "user" => user}

			return [200, JSON.generate(data)]
		end

		# This is just a test to play around with features
		get '/api/test/mongo/:application' do
			authorized, db = required_app_authorization(params[:application], params.key?("debug"))
			#protected_app!(params[:application])
			#authorized = authorized_app?(params[:application])
			"#{authorized}"
		end

		get '/api/test/clean' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = []

			authorized = false
			@auth ||=  Rack::Auth::Basic::Request.new(request.env)
		
			if @auth.provided? && @auth.basic? && @auth.credentials
				begin
					username = @auth.credentials[0]
					password = @auth.credentials[1]

					db = @conn.db("admin")
					authorized = db.authenticate(username, password)
					
					db = @conn.db("shift")
					col = db.collection("developers")
				
					dbs = []
						
					col.find().each { |row|
						if row.key?('applications')
							applications = row['applications']
							applications.each_key { |app_id|
								dbs << app_id
							}
						end
					}

					dbs.each { |row|
						@conn.drop_database(row)
					}
					@conn.drop_database('shift')

					authorized = true
					success = true

				rescue Mongo::AuthenticationError
				end
			end

			if !authorized
				if params.key?('debug')
					response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
					throw(:halt, [401, "Not authorized\n"])
				else 
					success = false
					err_msg = "Could not authenticate"
				end
			end
			
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
					
		end

	end
end
