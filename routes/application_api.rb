require 'error'
require 'util'
require 'logic/application'

module Route
	module ApplicationAPI

		# Inserts a document
		# Url:
		# Params:
		# * app_id
		# * collection
		# * insert_data
		post '/api/document/insert' do
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
				raise ShiftError.new(ShiftErrors.e01100_app_id_is_required)
			end

			# Checks if collection parameter exists
			if collection == nil
				raise ShiftError.new(ShiftErrors.e01101_collection_is_required)
			end

			# Checks if data parameter exists
			if insert_data == nil
				raise ShiftError.new(ShiftErrors.e01102_data_is_required)
			end

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			# Calls the logic function for insert document
			begin
				success = Logic::Application.insert_document(db, collection, insert_data)
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
		post '/api/document/update' do
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
				raise ShiftError.new(ShiftErrors.e01200_app_id_is_required)
			end

			# Checks if collection parameter exists
			if collection == nil
				raise ShiftError.new(ShiftErrors.e01201_collection_is_required)
			end

			# Checks if data parameter exists
			if insert_data == nil
				raise ShiftError.new(ShiftErrors.e01202_data_is_required)
			end

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			# Calls the logic function for update document
			begin
				data = Logic::Application.update_document(db, collection, insert_data)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end
			
			success = true	
			return Util.response(success, data)
		end

		# Delets a collection
		# Url:
		# * app_id
		# * collection
		# Params:
		get '/api/collections/delete/:app_id/:collection' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets clean url parameters
			app_id = params[:app_id]
			collection = params[:collection]

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			# Calls the logic function for delete collection
			begin
				success = Logic::Application.delete_collection(db, collection)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			unless success
				return Util.error_response(ShiftErrors.e01300_collection_not_deleted)
			end

			return Util.response(success, data)
		end

		# Deletes documents based on a query
		# Url:
		# * app_id
		# * collection
		# * query
		# Params:
		get '/api/documents/delete/:app_id/:collection/:query' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets clean url parameters
			app_id = params[:app_id]
			collection = params[:collection]
			query = params[:query]

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
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

		# List collections
		# Url:
		# * app_id
		# Params:
		get '/api/collection/list/:app_id' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {"collections" => []}

			# Gets clean url parameters
			app_id = params[:app_id]

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			# Calls the logic function for list collections
			begin
				data["collections"] = Logic::Application.list_collections(db)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end

		# Updates a collections name
		# Url:
		# Params:
		# * app_id
		# * collection
		# * new_name
		post '/api/collections/update' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {}

			# Gets post parameters
			app_id = params["app_id"]
			collection = params["collection"]
			new_name = params["new_name"]
				
			# Checks if app_id parameter exists
			if app_id == nil
				raise ShiftError.new(ShiftErrors.e01400_app_id_is_required)
			end
				
			# Checks if collection parameter exists
			if collection == nil
				raise ShiftError.new(ShiftErrors.e01401_collection_is_required)
			end
				
			# Checks if new_name parameter exists
			if new_name == nil
				raise ShiftError.new(ShiftErrors.e01402_new_name_is_required)
			end

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			# Calls the logic function for update collection
			begin
				success = Logic::Application.update_collection(@conn, app_id, collection, new_name)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			return Util.response(success, data)
			
		end

		# Updates a collections name
		# Url:
		# * app_id
		# * collection
		# * query
		# Params:
		get '/api/documents/query/:app_id/:collection/?:query?' do
			# Initializes response variables
			success = false
			err_msg = ""
			data = {"documents" => []}

			# Gets clean url parameters
			app_id = params[:app_id]
			collection = params[:collection]
			query = params[:query]

			# Verifies the application is authorized for this route and returns the MongoDB object
			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
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

	end
end
