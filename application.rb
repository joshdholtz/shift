module Shift
	module Application

		post '/document/insert' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets post parameters
			app_id = params["app_id"]
			collection = params["collection"]
			insert_data = params["data"]
				
			# Checks if app_id parameter exists
			if app_id == nil
				err_msg = "Please provide app_id"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Checks if collection parameter exists
			if collection == nil
				err_msg = "Please provide collection"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Checks if data parameter exists
			if insert_data == nil
				err_msg = "Please provide data"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				err_msg = "Error authenticating"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Attempts to authenticat the user into the application
			# and then inserts the data into the collection specified
			begin
				# Replaces the automatic MongoDB ObjectId with a UUID
				doc = JSON.parse(insert_data)
				doc["_id"] = UUID.new.generate(:compact)

				col = db.collection(collection)
				col.insert(doc)
			rescue JSON::ParserError
				# Catches after trying to parse the data
				err_msg = "Error parsing data"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
		end

		get '/collections/delete/:app_id/:collection' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets the query from the parameters
			app_id = params[:app_id]
			collection = params[:collection]

			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				err_msg = "Error authenticating"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Attempts to authenticat the user into the application
			# and then deletes the collection specified
			success = db.drop_collection(collection)
			unless success
				err_msg = "Collection does not exist"
			end

			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
		end

		get '/documents/delete/:app_id/:collection/:query' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets the query from the parameters
			app_id = params[:app_id]
			collection = params[:collection]
			query = params[:query]

			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				err_msg = "Error authenticating"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			begin
				query = JSON.parse(query)
			rescue JSON::ParserError
				# Catches after trying to parse the data
				err_msg = "Error parsing query"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Attempts to authenticat the user into the application
			# and then deletes the documents from the collection specified
			col = db.collection(collection)
			col.remove(query)

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
		end

		get '/collection/list/:app_id' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {"collections" => []}

			# Gets clean url parameters
			app_id = params[:app_id]

			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				err_msg = "Error authenticating"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Gets the list of collections within the application
			db.collection_names.each { |name| 
				unless name.start_with?("system.")
					data["collections"] << name 
				end
			}

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
		end

		get '/documents/query/:app_id/:collection/?:query?' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {"documents" => []}

			# Gets clean url parameters
			app_id = params[:app_id]
			collection = params[:collection]
			query = params[:query]

			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				err_msg = "Error authenticating"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Gets the query from the parameters
			if query != nil
				begin
					query = JSON.parse(query)
				rescue JSON::ParserError
					# Catches after trying to parse the data
					err_msg = "Error parsing query"
					return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
				end
			end

			# Attempts to authenticat the user into the application
			# and then queries from the collection specified
			col = db.collection(collection)

			cursor = (query == nil ? col.find() : col.find(query))
			cursor.each { |row| data["documents"] << row }

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
		end

	end
end
