require 'error'

module Logic
	module Application

		def Application.get_db(conn, user, app_id)
			db = nil

			if user.key?("applications") and user["applications"].key?(app_id)
				access_key = user["applications"][app_id]["app_id"]
				secret_key = user["applications"][app_id]["pass_key"]
				
				begin
					db = conn.db(app_id)
					authenticated = db.authenticate(access_key, secret_key)
				rescue Mongo::AuthenticationError
					raise ShiftError.new(ShiftErrors.e00000_invalid_app_authentication)
				end
			else
				raise ShiftError.new(ShiftErrors.e00008_invalid_app_id)
			end

			return db
		end

		def Application.create_collection(db, collection)
			success = false
			begin
				db.create_collection(collection)
				success = true
			rescue MongoDBError
				
			end

			return success
		end

		def Application.insert_document(db, collection, insert_data)
			# Attempts to authenticat the user into the application
			# and then inserts the data into the collection specified
			begin
				# Replaces the automatic MongoDB ObjectId with a UUID
				doc = JSON.parse(insert_data)
				doc["_id"] = UUID.new.generate(:compact)

				col = db.collection(collection)
				col.insert(doc)
			rescue JSON::ParserError
				raise ShiftError.new(ShiftErrors.e00004_could_not_parse_data)
			end

			return true
		end

		def Application.update_document(db, collection, insert_data)
			# Attempts to authenticat the user into the application
			# and then updates the data into the collection specified
			doc = nil
			begin
				# Replaces the automatic MongoDB ObjectId with a UUID
				doc = JSON.parse(insert_data)
			rescue JSON::ParserError
				raise ShiftError.new(ShiftErrors.e00004_could_not_parse_data)
			end

			unless doc.key?("_id")
				doc["_id"] = UUID.new.generate(:compact)
			end

			col = db.collection(collection)
			col.save(doc)

			return doc
		end

		def Application.delete_collection(db, collection)
			# Attempts to authenticat the user into the application
			# and then deletes the collection specified
			success = db.drop_collection(collection)
			return success
		end

		def Application.delete_documents(db, collection, query)
			begin
				query = JSON.parse(query)
			rescue JSON::ParserError
				raise ShiftError.new(ShiftErrors.e00004_could_not_parse_data)
			end

			# Attempts to authenticat the user into the application
			# and then deletes the documents from the collection specified
			col = db.collection(collection)
			col.remove(query)
			
			# TODO Check to make sure query does not return any result

			return true
		end

		def Application.list_collections(db)
			collections = Array.new

			# Gets the list of collections within the application
			db.collection_names.each { |name| 
				unless name.start_with?("system.")
					collections << name 
				end
			}

			return collections
		end

		def Application.update_collection(conn, app_id, collection, new_name)
			# NOTE This is a workaround for now since renaming a collection in mongo as an "admin" function
			# Authenticates
			db = conn.db("admin")
			db.authenticate("admin", "admin")

			# Gets connection to 'shift' collection
			db = conn.db(app_id)
			db.rename_collection(collection, new_name)

			return true
		end

		def Application.query_documents(db, collection, query=nil)
			# Gets the query from the parameters
			if query != nil
				begin
					query = JSON.parse(query)
				rescue JSON::ParserError
					raise ShiftError.new(ShiftErrors.e00004_could_not_parse_data)
				end
			end

			# Attempts to authenticat the user into the application
			# and then queries from the collection specified
			col = db.collection(collection)

			documents = Array.new
			cursor = (query == nil ? col.find() : col.find(query))
			cursor.each { |row| documents << row }

			return documents
		end

	end
end
