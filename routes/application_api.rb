require 'error'
require 'util'
require 'logic/application'

module Route
	module ApplicationAPI

		# Logs in an application
		# Url:
		# Params:
		# * app_id
		post '/api/app/login' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Verifies the application is authorized for this route and returns the MongoDB object
			app_id, authorized, db = required_app_authorization(params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			# Authenticates
			db = @conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'application_sessions' collection
			db = @conn.db("shift")
			col = db.collection("application_sessions")

			# Generates token and inserts it into the session collection
			token = UUID.new.generate
			col.insert( {"_id" => token, "app_id" => app_id} )

			success = true
			data["token"] = token
			return Util.response(success, data)

		end

		# Logs out an application
		# Url:
		# Params:
		post '/api/app/logout' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}
				
			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = valid_app_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00006_invalid_app_token)
			end

			# Gets token from header
			token = env["HTTP_TOKEN"]

			# Authenticates
			db = @conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'application_sessions' collection
			db = @conn.db("shift")
			col = db.collection("application_sessions")

			# Removes token from the session collection
			col.remove( {"_id" => token} )

			success = true
			return Util.response(success, data)

		end

		# Queries documents
		# Url:
		# * app_id
		# * collection
		# * query
		# Params:
		get '/api/doc/:collection/?:query?' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {"documents" => []}

			# Gets clean url parameters
			collection = params[:collection]
			query = params[:query]

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = valid_app_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00006_invalid_app_token)
			end

			# Calls the logic function for query documents
			begin
				data["documents"] = Logic::Application.query_documents(db, collection, query)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end

		# Inserts a document
		# Url:
		# Params:
		# * app_id
		# * collection
		# * insert_data
		post '/api/doc/:collection' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets post parameters
			collection = params[:collection]
			document = params["document"]

			# Checks if data parameter exists
			if document == nil
				return Util.error_response(ShiftErrors.e01102_data_is_required)
			end

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = valid_app_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00006_invalid_app_token)
			end

			# Calls the logic function for insert document
			begin
				data = Logic::Application.insert_document(db, collection, document)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end

		# Updates a document
		# Url:
		# Params:
		# * app_id
		# * collection
		# * insert_data
		put '/api/doc/:collection' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets post parameters
			collection = params[:collection]
			document = params["document"]

			# Checks if data parameter exists
			if document == nil
				return Util.error_response(ShiftErrors.e01202_data_is_required)
			end

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = valid_app_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00006_invalid_app_token)
			end

			# Calls the logic function for update document
			begin
				data = Logic::Application.update_document(db, collection, document)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end
			
			success = true	
			return Util.response(success, data)
		end

		# Deletes documents based on a query
		# Url:
		# * app_id
		# * collection
		# * query
		# Params:
		delete  '/api/doc/:collection/:query' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets clean url parameters
			collection = params[:collection]
			query = params[:query]

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = valid_app_token?
			unless authorized
				return Util.error_response(ShiftErrors.e00006_invalid_app_token)
			end

			# Calls the logic function for delete documents
			begin
				success = Logic::Application.delete_documents(db, collection, query)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end

	end
end
