module Shift
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
				err_msg = "Please provide email"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Checks if password parameter exists
			if password == nil
				err_msg = "Please provide password"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end
			
			# Authenticates
			db = @conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'developers' collection
			db = @conn.db("shift")
			col = db.collection("developers")
			
			# Checks if an account with the email already exists
			if col.find_one( {"email" => email} ) != nil
				err_msg = "Cannot register - this email already exists"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Inserts the user
			doc = col.insert( {"email" => email, "password" => password} )
			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )

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
			if name  == nil
				err_msg = "Please provide name"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			authorized, user = required_user_authorization(params.key?("debug"))
			unless authorized
				err_msg = "Authorization failed"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			id = user['_id']

			# Generates keys for the app key and secret key
			app_id = UUID.new.generate(:compact)
			access_key = UUID.new.generate
			secret_key = UUID.new.generate

			# Authenticates
			db = @conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'shift' collection
			db = @conn.db("shift")
			col = db.collection("developers")

			# Check if an account with the id doesn't exist
			if col.find_one( {"_id" => id} ) == nil
				err_msg = "Developer id does not exist"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			app = {"app_id" => app_id,
				"name" => name, 
				"access_key" => access_key, 
				"secret_key" => secret_key}

			# Adds the developer to a users collection
			col.update({"_id" => id}, {"$set" => { "applications." + app_id => app } })

			# Creates a new database for the application
			db = @conn.db(app_id)
			db.add_user(access_key, secret_key)

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => app} )

		end

		get '/applications/list' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			authorized, user = required_user_authorization(params.key?("debug"))
			unless authorized
				err_msg = "Authorization failed"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Gets the list of applications the user owns
			if user.key?("applications")
				data["applications"] = user["applications"].values()
			end

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )

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
				err_msg = "Authorization failed"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			id = user["_id"]

			# Authenticates
			db = @conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'shift' collection
			db = @conn.db("shift")
			col = db.collection("developers")

			# Checks if user own application
			if col.find_one( {"_id" => id, "applications." + app_id => { "$exists" => true }  } ) == nil
				err_msg = "Developer does not own this app - " + id.to_s + ", " + app_id
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => user["applications"][app_id]} )
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
			if name  == nil
				err_msg = "Please provide name"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			authorized, user = required_user_authorization(params.key?("debug"))
			unless authorized
				err_msg = "Authorization failed"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			id = user['_id']

			# Authenticates
			db = @conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'shift' collection
			db = @conn.db("shift")
			col = db.collection("developers")

			# Checks if user own application
			if col.find_one( {"_id" => id, "applications." + app_id => { "$exists" => true }  } ) == nil
				err_msg = "Developer does not own this app - " + id.to_s + ", " + app_id
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# TODO Check for hash if error occurred
			# Updates the application information
			col.update({"_id" => id}, { "$set" => {"applications." + app_id + ".name" => name } } )
		
			# Gets updated application for response	
			data = col.find_one( {"_id" => id, "applications." + app_id => { "$exists" => true }  } )

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data["applications"][app_id]} )

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
				err_msg = "Authorization failed"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			id = user['_id']

			# Authenticates
			db = @conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'shift' collection
			db = @conn.db("shift")
			col = db.collection("developers")

			# Checks if user own application
			if col.find_one( {"_id" => id, "applications." + app_id => { "$exists" => true }  } ) == nil
				err_msg = "Developer does not own this app - " + id.to_s + ", " + app_id
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			@conn.drop_database(app_id)

			# TODO Check for hash if error occurred
			# Removes application
			col.update({"_id" => id}, {"$unset" => { "applications." + app_id => app } })
			
			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )

		end

	end
end
