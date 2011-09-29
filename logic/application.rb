require 'error'

module Logic
	module Application

		def Application.get_db(user, app_id)

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
				raise ShiftError.new(ShiftErrors.e01203_document_id_is_required)
			end

			col = db.collection(collection)
			if col.find_one({ "_id" => doc["_id"] }) == nil
				raise ShiftError.new(ShiftErrors.e01204_document_doesnt_exist)
			end

			col.update({ "_id" => doc["_id"] }, doc)
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