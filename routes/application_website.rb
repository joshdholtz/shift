require 'error'
require 'util'
require 'json'
require 'logic/user'
require 'logic/application'

module Route
	module ApplicationWebsite

		get '/collection/list/:app_id' do
			# Gets clean url parameters
			@app_id = params[:app_id]

			@id = session["id"]

			# Calls the logic function for create application
			begin
				user = Logic::User.get_user(@conn, @id)
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
