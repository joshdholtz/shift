module Shift
	module Application

		get '/application/:application/:collection/insert' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			authorized, db = required_app_authorization(params[:application], params.key?("debug"))
			unless authorized
				err_msg = "Error authenticating"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Attempts to authenticat the user into the application
			# and then inserts the data into the collection specified
			begin
				# Replaces the automatic MongoDB ObjectId with a UUID
				doc = JSON.parse(params["data"])
				doc["_id"] = UUID.new.generate(:compact)

				col = db.collection(params[:collection])
				col.insert(doc)
			rescue JSON::ParserError
				# Catches after trying to parse the data
				err_msg = "Error parsing data"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
		end

		get '/application/:application/delete/:collection' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			authorized, db = required_app_authorization(params[:application], params.key?("debug"))
			unless authorized
				err_msg = "Error authenticating"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Attempts to authenticat the user into the application
			# and then deletes the collection specified
			success = db.drop_collection(params[:collection])
			unless success
				err_msg = "Collection does not exist"
			end

			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
		end

		get '/application/:application/:collection/delete/:query' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			authorized, db = required_app_authorization(params[:application], params.key?("debug"))
			unless authorized
				err_msg = "Error authenticating"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Gets the query from the parameters
			query = params[:query]

			begin
				query = JSON.parse(query)
			rescue JSON::ParserError
				# Catches after trying to parse the data
				err_msg = "Error parsing query"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Attempts to authenticat the user into the application
			# and then deletes the documents from the collection specified
			col = db.collection(params[:collection])
			col.remove(query)

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
		end

		get '/application/:application/query' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {"collections" => []}

			authorized, db = required_app_authorization(params[:application], params.key?("debug"))
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

		get '/application/:application/:collection/query/?:query?' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {"documents" => []}

			authorized, db = required_app_authorization(params[:application], params.key?("debug"))
			unless authorized
				err_msg = "Error authenticating"
				return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
			end

			# Gets the query from the parameters
			query = params[:query]
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
			col = db.collection(params[:collection])

			cursor = (query == nil ? col.find() : col.find(query))
			cursor.each { |row| data["documents"] << row }

			success = true
			return JSON.generate( {"success" => success, "err_msg" => err_msg, "data" => data} )
		end

	end
end
