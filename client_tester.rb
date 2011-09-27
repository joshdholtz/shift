require 'net/http'
require 'uri'
require 'json'

@base_url = "http://thirdshift.dyndns.org:4567/api"

Auth = Struct.new(:username, :password)

def post(url, post_params, auth=nil)
	url = URI.parse(url)

    	req = Net::HTTP::Post.new(url.path)
	req.form_data = post_params
	unless auth == nil
		req.basic_auth auth.username, auth.password
	end

	resp = Net::HTTP.start(url.host, url.port) {|http|
		#req.basic_auth 'joshdholtz@gmail.com', 'test1'
		http.request(req)
	}

	return resp.body
end

def get(url, auth=nil)
	url = URI.parse(url)

    	req = Net::HTTP::Get.new(url.path)
	unless auth == nil
		req.basic_auth auth.username, auth.password
	end

	resp = Net::HTTP.start(url.host, url.port) {|http|
		http.request(req)
	}

	return resp.body
end

def read_in(prompt)
	print "\n" + prompt + ": "
	std_in = gets
	return std_in.strip
end

def read_in_auth()
	username = read_in("Username")
	password = read_in("Password")
	return Auth.new(username, password)
end

def test()
	return get(@base_url + "/test")
end

def test_clean(auth)
	return get(@base_url + "/test/clean", auth)
end

# User register
def register_user(email, password)
	return post(@base_url + "/user/register",  {"email" => email, "password" => password} )
end

# Create application
def create_application(name, auth)
	return post(@base_url + "/applications/create",  {"name" => name}, auth)
end

# List applications
def list_applications(auth)
	return get(@base_url + "/applications/list", auth)
end

# Find application
def find_application(app_id, auth)
	return get(@base_url + "/applications/find/" + app_id, auth)
end

# Update application
def update_application(app_id, name, auth)
	return post(@base_url + "/applications/update/" + app_id,  {"name" => name}, auth)
end

# Delete application
def delete_application(app_id, auth)
	return get(@base_url + "/applications/delete/" + app_id, auth)
end

# List collections
def list_collection(app_id, auth)
	return get(@base_url + "/collection/list/" + app_id, auth)
end

# Rename collection
def rename_collection(app_id, collection, new_name, auth)
	return post(@base_url + "/collections/update", {"app_id" => app_id, "collection" => collection, "new_name" => new_name}, auth)
end

# Delete collection
def delete_collection(app_id, collection, auth)
	return get(@base_url + "/collections/delete/" + app_id + "/" + collection, auth)
end

# Insert document
def insert_document(app_id, collection, data, auth)
	return post(@base_url + "/document/insert",  {"app_id" => app_id, "collection" => collection, "data" => data}, auth)
end

# Update document
def update_document(app_id, collection, data, auth)
	return post(@base_url + "/document/update",  {"app_id" => app_id, "collection" => collection, "data" => data}, auth)
end

# Query documents
def query_documents(app_id, collection, query, auth)
	if query == nil
		query = ""
	else
		query = "/" + query
	end

	return get(@base_url + "/documents/query/" + app_id + "/" + collection + query, auth)
end

# Delete documents
def delete_documents(app_id, collection, query, auth)
	query = URI.escape(query)
	return get(@base_url + "/documents/delete/" + app_id + "/" + collection + "/" + query, auth)
end

def run_test
	#Test clean
	resp = JSON.parse(test_clean(Auth.new("admin", "admin")))
	puts "** Test clean"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - test clean"
		return
	end
	
	#Register user
	resp = JSON.parse(register_user("joshdholtz@gmail.com", "test1"))	
	puts "** Register user"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - register user"
		return
	end

	#Create application
	resp = JSON.parse(create_application("App1", Auth.new("joshdholtz@gmail.com", "test1")))
	puts "** Create application"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - create application"
		return
	end
	app_id = resp["data"]["app_id"]
	access_key = resp["data"]["access_key"]
	secret_key = resp["data"]["secret_key"]

	#List application
	resp = JSON.parse(list_applications(Auth.new("joshdholtz@gmail.com", "test1")))
	puts "** List application"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - list applications"
		return
	end
	applications = resp["data"]["applications"]
	if applications.empty?
		puts "Applications should not be empty"
		return
	end
	if applications.size != 1
		puts "Applications should only contain one applications"
		return
	end
	if applications[0]["app_id"] != app_id
		puts "Applications should only contain \"" + app_id + "\" application"
		return
	end

	#Find application
	resp = JSON.parse(find_application(app_id, Auth.new("joshdholtz@gmail.com", "test1")))
	puts "** Find application"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - find application"
		return
	end
	application = resp["data"]
	if application["app_id"] != app_id
		puts "Application' app_id should equal " + app_id
		return
	end
	if application["name"] != "App1"
		puts "Application's name should equal App1" 
		return
	end
	
	#Update application
	resp = JSON.parse(update_application(app_id, "App2", Auth.new("joshdholtz@gmail.com", "test1")))
	puts "** Update application"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - update application"
		return
	end
	application = resp["data"]
	if application["app_id"] != app_id
		puts "Application's app_id should equal " + app_id
		return
	end
	if application["name"] != "App2"
		puts "Application's name should equal App2" 
		return
	end

	#Insert document
	resp = JSON.parse(insert_document(app_id, "contacts", JSON.generate( {"first_name" => "Josh", "last_name" => "Holtz", "age" => 22 } ), Auth.new(access_key, secret_key)))
	puts "** Insert document"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - insert document"
		return
	end

	#List collections
	resp = JSON.parse(list_collection(app_id, Auth.new(access_key, secret_key)))
	puts "** List collections"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - list collections"
		return
	end
	collections = resp["data"]["collections"]
	if collections.empty?
		puts "Collections should not be empty"
		return
	end
	if collections.size != 1
		puts "Collections should only contain one collection"
		return
	end
	if collections[0] != "contacts"
		puts "Collections should only contain \"contacts\" collection"
		return
	end

	#Rename collection
	resp = JSON.parse(rename_collection(app_id, "contacts", "friends", Auth.new(access_key, secret_key)))
	puts "** Rename collection"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - rename collection"
		return
	end

	#List collections
	resp = JSON.parse(list_collection(app_id, Auth.new(access_key, secret_key)))
	puts "** List collections"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - list collections"
		return
	end
	collections = resp["data"]["collections"]
	if collections.empty?
		puts "Collections should not be empty"
		return
	end
	if collections.size != 1
		puts "Collections should only contain one collection"
		return
	end
	if collections[0] != "friends"
		puts "Collections should only contain \"friends\" collection"
		return
	end

	#Query document
	resp = JSON.parse(query_documents(app_id, "friends", nil, Auth.new(access_key, secret_key)))
	puts "** Query document"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - query document"
		return
	end
	documents = resp["data"]["documents"]
	if documents.empty?
		puts "Documentss should not be empty"
		return
	end
	if documents.size != 1
		puts "Documents should only contain one document"
		return
	end
	if !documents[0].key?("_id")
		puts "Documents should have _id"
		return
	end
	if documents[0]["first_name"] != "Josh"
		puts "Documents first_name should be Josh"
		return
	end
	if documents[0]["last_name"] != "Holtz"
		puts "Documents last_name should be Holtz"
		return
	end
	if documents[0]["age"] != 22
		puts "Documents age should be 22"
		return
	end
	doc_id = documents[0]["_id"]
	doc_to_update = documents[0]

	#Update document
	doc_to_update["age"] = 23
	resp = JSON.parse(update_document(app_id, "friends", JSON.generate(doc_to_update), Auth.new(access_key, secret_key)))
	puts "** Update document"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - update document"
		return
	end
	documents = resp["data"]
	if documents.empty?
		puts "Documentss should not be empty"
		return
	end
	if !documents.key?("_id")
		puts "Documents should have _id"
		return
	end
	if documents["first_name"] != "Josh"
		puts "Documents first_name should be Josh"
		return
	end
	if documents["last_name"] != "Holtz"
		puts "Documents last_name should be Holtz"
		return
	end
	if documents["age"] != 23
		puts "Documents age should be 23"
		return
	end

	#Delete document
	resp = JSON.parse(delete_documents(app_id, "friends", JSON.generate( {"_id" => doc_id } ), Auth.new(access_key, secret_key)))
	puts "** Delete document"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - delete document"
		return
	end

	#Query document after deletion
	resp = JSON.parse(query_documents(app_id, "friends", nil, Auth.new(access_key, secret_key)))
	puts "** Query docoument"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - query document after deletion"
		return
	end
	documents = resp["data"]["documents"]
	if !documents.empty?
		puts "Documentss should be empty"
		return
	end

	#Delete collection
	resp = JSON.parse(delete_collection(app_id, "friends", Auth.new(access_key, secret_key)))
	puts "** Delete collection"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - delete collection"
		return
	end

	#List collections after deletion
	resp = JSON.parse(list_collection(app_id, Auth.new(access_key, secret_key)))
	puts "** List collections"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - list collections after deletion"
		return
	end
	collections = resp["data"]["collections"]
	if !collections.empty?
		puts "Collections should not be empty"
		return
	end

	#Delete application
	resp = JSON.parse(delete_application(app_id,  Auth.new("joshdholtz@gmail.com", "test1")))
	puts "** Delete application"
	puts resp.inspect
	unless resp["success"]
		puts "FAILED - delete application"
		return
	end

end

if __FILE__ == $0
	run_test()
end
