require 'error'
require 'util'
require 'logic/application'

module Route
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

			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			begin
				success = Logic::Application.insert_document(db, collection, insert_data)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end

		post '/document/update' do
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

			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			begin
				data = Logic::Application.update_document(db, collection, insert_data)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end
			
			success = true	
			return Util.response(success, data)
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
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

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
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			begin
				success = Logic::Application.delete_documents(db, collection, query)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
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
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			begin
				data["collections"] = Logic::Application.list_collections(db)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			success = true
			return Util.response(success, data)
		end

		post '/collections/update' do
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

			authorized, db = required_app_authorization(app_id, params.key?("debug"))
			unless authorized
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

			begin
				success = Logic::Application.update_collection(@conn, app_id, collection, new_name)
			rescue ShiftError => boom
				return Util.error_response(boom.error)
			end

			return Util.response(success, data)
			
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
				return Util.error_response(ShiftErrors.e00000_invalid_app_authentication)
			end

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
