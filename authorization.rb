module Shift
	module Authorization

		def required_user_authorization(debug)
			authorized = false
			user = nil

			if debug
				authorized, user = protected_user!
			else
				authorized, user = authorized_user?
			end

			return authorized, user
		end

		def protected_user!()
			authorized, user = authorized_user?
			unless authorized
				response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
				throw(:halt, [401, "Not authorized\n"])
			end

			return authorized, user
		end

		def authorized_user?(email=nil, password=nil)
			authenticated = false
			user = nil
		
			if email == nil and password == nil	
				@auth ||=  Rack::Auth::Basic::Request.new(request.env)
			
				if @auth.provided? && @auth.basic? && @auth.credentials
					email = @auth.credentials[0]
					password = @auth.credentials[1]
				end
			end
			
			if email != nil and password != nil
				begin
					
					db = @conn.db("admin")
					db.authenticate("admin", "admin")
					
					db = @conn.db("shift")
					col = db.collection("developers")

					puts "Count: " + col.find().count().to_s
					user = col.find_one( {"email" => email, "password" => password} )

					unless user == nil
						authenticated = true
					end
				rescue Mongo::AuthenticationError
					puts "Mongo authentication error"
				end
			end

			return authenticated, user
		end

		def valid_user_token?
			authorized = false
			user = nil

			if env["HTTP_TOKEN"] != nil
				token = env["HTTP_TOKEN"]

				db = @conn.db("admin")
				db.authenticate("admin", "admin")
				
				db = @conn.db("shift")
				col = db.collection("user_sessions")

				token_data = col.find_one( {"_id" => token } )
				if token_data != nil
					user_id = token_data["user_id"]
					
					col = db.collection("developers")
					user = col.find_one( {"_id" => user_id} )

					authorized = (user != nil)
				end

			end

			return authorized, user

		end

		def required_app_authorization(app_id,debug)
			authorized = false
			db = nil

			if debug
				authorized, db = protected_app!(app_id)
			else
				authorized, db = authorized_app?(app_id)
			end

			return authorized, db
		end

		def protected_app!(app_id)
			authorized, db = authorized_app?(app_id)
			unless authorized
				response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
				throw(:halt, [401, "Not authorized\n"])
			end

			return authorized, db
		end

		def authorized_app?(app_id)
			authenticated = false
			db = nil

			@auth ||=  Rack::Auth::Basic::Request.new(request.env)
		
			if @auth.provided? && @auth.basic? && @auth.credentials
				begin
					db = @conn.db(app_id)
					authenticated = db.authenticate(@auth.credentials[0], @auth.credentials[1])
				rescue Mongo::AuthenticationError

				end
			end

			return authenticated, db
		end

		def valid_app_token?
			authorized = false
			db = nil

			if env["HTTP_TOKEN"] != nil
				token = env["HTTP_TOKEN"]

				db_admin = @conn.db("admin")
				db_admin.authenticate("admin", "admin")
				
				db_admin = @conn.db("shift")
				col = db_admin.collection("application_sessions")

				token_data = col.find_one( {"_id" => token } )
				if token_data != nil
					app_id = token_data["app_id"]

					db = @conn.db(app_id)
					authorized = (db != nil)
				end

			end

			return authorized, db

		end

	end
end
