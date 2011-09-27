require 'error'

module Logic
	module User

		def User.user_register(conn, email, password)
			# Authenticates
			db = conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'developers' collection
			db = conn.db("shift")
			col = db.collection("developers")
			
			# Checks if an account with the email already exists
			if col.find_one( {"email" => email} ) != nil
				raise ShiftError.new(ShiftErrors.e00103_user_already_exists)
			end

			# Inserts the user
			doc = col.insert( {"email" => email, "password" => password} )

			return true
		end

		def User.create_application(conn, id, name)
			# Generates keys for the app key and secret key
			app_id = UUID.new.generate(:compact)
			access_key = UUID.new.generate
			secret_key = UUID.new.generate

			# Authenticates
			db = conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'shift' collection
			db = conn.db("shift")
			col = db.collection("developers")

			# Check if an account with the id doesn't exist
			if col.find_one( {"_id" => id} ) == nil
				raise ShiftError.new(ShiftErrors.e00002_developer_id_doesnt_exist)
			end

			app = {"app_id" => app_id,
				"name" => name, 
				"access_key" => access_key, 
				"secret_key" => secret_key}

			# Adds the developer to a users collection
			col.update({"_id" => id}, {"$set" => { "applications." + app_id => app } })

			# Creates a new database for the application
			db = conn.db(app_id)
			db.add_user(access_key, secret_key)
			
			return app
		end

		def User.list_applications(user)
			applications = Array.new

			# Gets the list of applications the user owns
			if user.key?("applications")
				applications  = user["applications"].values()
			end

			return applications
		end

		def User.find_application(conn, user, app_id)
			# Authenticates
			db = conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'shift' collection
			db = conn.db("shift")
			col = db.collection("developers")

			# Checks if user own application
			if col.find_one( {"_id" => user["_id"], "applications." + app_id => { "$exists" => true }  } ) == nil
				raise ShiftError.new(ShiftErrors.e00003_developer_doesnt_own_app)
			end
			
			return user["applications"][app_id]
		end

		def User.update_application(conn, user, app_id, name)
			# Authenticates
			db = conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'shift' collection
			db = conn.db("shift")
			col = db.collection("developers")

			id = user["_id"]

			# Checks if user own application
			if col.find_one( {"_id" => id, "applications." + app_id => { "$exists" => true }  } ) == nil
				raise ShiftError.new(ShiftErrors.e00003_developer_doesnt_own_app)
			end

			# TODO Check for hash if error occurred
			# Updates the application information
			col.update({"_id" => id}, { "$set" => {"applications." + app_id + ".name" => name } } )
		
			# Gets updated application for response	
			data = col.find_one( {"_id" => id, "applications." + app_id => { "$exists" => true }  } )

			return data["applications"][app_id]
		end

		def User.delete_application(conn, user, app_id)
			# Authenticates
			db = conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'shift' collection
			db = conn.db("shift")
			col = db.collection("developers")

			id = user["_id"]

			# Checks if user own application
			if col.find_one( {"_id" => id, "applications." + app_id => { "$exists" => true }  } ) == nil
				err_msg = "Developer does not own this app - " + id.to_s + ", " + app_id
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			conn.drop_database(app_id)

			# TODO Check for hash if error occurred
			# Removes application
			col.update({"_id" => id}, {"$unset" => { "applications." + app_id => 1 } })

			return true
		end

	end
end
