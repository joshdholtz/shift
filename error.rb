class ShiftErrorMessage
	attr_accessor :err_id, :err_msg
	
	def initialize(err_id, err_msg)
		@err_id = err_id
		@err_msg = err_msg
	end

end

class ShiftError < StandardError

	attr_accessor :error

	def initialize(error)
		super(error.err_msg)
		@error = error
	end

end

module ShiftErrors

	module_function	

	# General errors
	@e00000 = ShiftErrorMessage.new("00000", "Invalid user authentication")
	def e00000_invalid_user_authentication; @e00000 end

	@e00001 = ShiftErrorMessage.new("00001", "Invalid app authentication")
	def e00001_invalid_application_authentication; @e00001 end

	@e00002 = ShiftErrorMessage.new("00002", "Developer id does not exist")
	def e00002_developer_id_doesnt_exist; @e00002 end

	@e00003 = ShiftErrorMessage.new("00003", "Developer does not own this application")
	def e00003_developer_doesnt_own_app; @e00003 end

	@e00004 = ShiftErrorMessage.new("00004", "Could not parse data")
	def e00004_could_not_parse_data; @e00004 end
	
	@e000005 = ShiftErrorMessage.new("00005", "Invalid or expired user token")
	def e00005_invalid_user_token; @e00005 end
	
	@e000006 = ShiftErrorMessage.new("00006", "Invalid or expired application token")
	def e00006_invalid_app_token; @e00006 end
	
	@e000007 = ShiftErrorMessage.new("00007", "Invalid user id")
	def e00007_invalid_user_id; @e00007 end

	# User register errors 
	@e00100 = ShiftErrorMessage.new("00100", "Email is required for user registration")
	def e00100_email_is_required; @e00100 end

	@e00101 = ShiftErrorMessage.new("00101", "Password is required for user registration")
	def e00101_password_is_required; @e00101 end

	@e00102 = ShiftErrorMessage.new("00102", "Please provide a valid email address")
	def e00102_invalid_email_address; @e00102 end

	@e00103 = ShiftErrorMessage.new("00103", "User with that email already exists")
	def e00103_user_already_exists; @e00103 end

	# Create application errors 
	@e00200 = ShiftErrorMessage.new("00200", "Name is required for create application")
	def e00200_name_is_required; @e00200 end

	# Update application errors 
	@e00300 = ShiftErrorMessage.new("00300", "Name is required for update application")
	def e00300_name_is_required; @e00300 end

	# Document insert errors
	@e01100 = ShiftErrorMessage.new("01100", "App Id is required for insert document")
	def e01100_app_id_is_required; @e01100 end

	@e01101 = ShiftErrorMessage.new("01101", "Collection is required for insert document")
	def e01101_collection_is_required; @e01101 end

	@e01102 = ShiftErrorMessage.new("01102", "Data is required for insert document")
	def e01102_data_is_required; @e01102 end

	# Document update errors
	@e01200 = ShiftErrorMessage.new("01200", "App Id is required for update document")
	def e01200_app_id_is_required; @e01200 end

	@e01201 = ShiftErrorMessage.new("01201", "Collection is required for update document")
	def e01201_collection_is_required; @e01201 end

	@e01202 = ShiftErrorMessage.new("01202", "Data is required for update document")
	def e01202_data_is_required; @e01202 end

	@e01203 = ShiftErrorMessage.new("01203", "_id is a required field in data for update document")
	def e01203_document_id_is_required; @e01203 end

	@e01204 = ShiftErrorMessage.new("01204", "Document with this _id doesn't exist")
	def e01204_document_doesnt_exist; @e01204 end

	# Delete collection  errors
	@e01300 = ShiftErrorMessage.new("01300", "Collection could not be deleted")
	def e01300_collection_not_deleted; @e01300 end

	# Collection update errors
	@e01400 = ShiftErrorMessage.new("01400", "App Id is required for update collection")
	def e01400_app_id_is_required; @e01400 end

	@e01401 = ShiftErrorMessage.new("01401", "Collection is required for update collection")
	def e01401_collection_is_required; @e01401 end

	@e01402 = ShiftErrorMessage.new("01402", "New name is required for update collection")
	def e01402_new_name_is_required; @e01402 end

end
