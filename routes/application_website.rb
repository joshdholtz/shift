require 'error'
require 'util'
require 'json'
require 'logic/user'
require 'logic/application'

module Route
	module ApplicationWebsite

		get '/app/:app_id/collections/:collection/doc/create' do
			@id = session["id"]

			# Gets clean url parameters
			@app_id = params[:app_id]
			@collection = params[:collection]

			erb :create_document
		end

		post '/app/:app_id/collections/:collection/doc/create' do
			@id = session["id"]

			# Gets clean url parameters
			@app_id = params[:app_id]
			@collection = params[:collection]

			# Gets post parameters
			document = params["document"]
				
			# Checks if document parameter exists
			if document.empty?
				last_err = "Please provide a document"
				session["last_err"] = last_err
				redirect '/app/' + @app_id + '/collections/' + @collection + '/doc/create'
			end

			# Calls the logic function for create document
			begin
				user = Logic::User.get_user(@conn, @id)
				db = Logic::Application.get_db(@conn, user, @app_id)

				document = Logic::Application.insert_document(db, @collection, document)

				successful = true
			rescue ShiftError => boom
				last_err = boom.error.err_msg
				session["last_err"] = last_err
				redirect '/app/' + @app_id + '/collections/' + @collection + '/doc/create'
			end

			redirect '/documents/query/' + @app_id + '/' + @collection

		end

		get '/app/:app_id/collections/create' do
			@id = session["id"]

			# Gets clean url parameters
			@app_id = params[:app_id]

			erb :create_collection
		end

		post '/app/:app_id/collections/create' do
			@id = session["id"]

			# Gets clean url parameters
			@app_id = params[:app_id]

			# Gets post parameters
			collection = params["collection"]
				
			# Checks if collection parameter exists
			if collection.empty?
				last_err = "Please provide a collection name"
				session["last_err"] = last_err
				redirect '/app/' + @app_id + '/collections/create'
			end

			# Calls the logic function for create collection
			begin
				user = Logic::User.get_user(@conn, @id)
				db = Logic::Application.get_db(@conn, user, @app_id)

				@collections = Logic::Application.create_collection(db, collection)

				successful = true
			rescue ShiftError => boom
				last_err = boom.error.err_msg
				session["last_err"] = last_err
				redirect '/app/' + @app_id + '/collections/create'
			end

			redirect '/collection/list/' + @app_id
		end

		get '/collection/list/:app_id' do
			# Gets clean url parameters
			@app_id = params[:app_id]

			@id = session["id"]

			# Calls the logic function for create application
			begin
				user = Logic::User.get_user(@conn, @id)
				@app_name = user['applications'][@app_id]['name']

				db = Logic::Application.get_db(@conn, user, @app_id)

				@collections = Logic::Application.list_collections(db)

				successful = true
			rescue ShiftError => boom
				last_err = boom.error.err_msg
				session["last_err"] = last_err
			end

			erb :list_collections

		end

		get '/documents/query/:app_id/:collection' do
			# Gets clean url parameters
			@app_id = params[:app_id]
			@collection = params[:collection]

			@id = session["id"]

			# Calls the logic function for create application
			begin
				user = Logic::User.get_user(@conn, @id)
				@app_name = user['applications'][@app_id]['name']

				db = Logic::Application.get_db(@conn, user, @app_id)

				@documents = Logic::Application.query_documents(db, @collection)

				successful = true
			rescue ShiftError => boom
				last_err = boom.error.err_msg
				session["last_err"] = last_err
			end

			erb :query_documents

		end

	end
end
