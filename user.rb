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
			db.authenticate("root", "velenspeok0301")

			# Gets connection to 'developers' collection
			db = @conn.db("shift")
			col = db.collection("developers")
			
			# Checks if an account with the email already exists
			if col.find_one( {"email" => email}) != nil
				err_msg = "Cannot register - this email already exists"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Inserts the user
			doc = col.insert( {"email" => email, "password" => password} )
			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )

		end

		# TODO Move url params to post params
		# Creates an application under a user
		get '/application/create/:id/:name' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Generates keys for the app key and secret key
			app_id = UUID.new.generate(:compact)
			access_key = UUID.new.generate
			secret_key = UUID.new.generate

			# Authenticates
			db = @conn.db("admin")
			db.authenticate("root", "velenspeok0301")

			# Gets connection to 'shift' collection
			db = @conn.db("shift")
			col = db.collection("developers")

			# Check if an account with the id doesn't exist
			if col.find_one( {"_id" => BSON::ObjectId.from_string(params[:id])} ) == nil
				err_msg = "Developer id does not exist"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			app = { "applications" => 
					{"app_id" => app_id,
					"name" => params[:name], 
					"access_key" => access_key, 
					"secret_key" => secret_key}
				}

			# Adds the developer to a users collection
			col.update({"_id" => BSON::ObjectId.from_string(params[:id])}, {"$push" => app})

			# Creates a new database for the application
			db = @conn.db(app_id)
			db.add_user(access_key, secret_key)

			success = true
			data = app # Probably real bad practice and should prob take out by I like consistent
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )

		end

	end
end
