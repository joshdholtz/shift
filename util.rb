require 'json'

module Util

	def Util.response(success, data, err_id="", err_msg="")
		return JSON.generate( {"success" => success, "err_id" => err_id, "err_msg" => err_msg, "data" => data} )
	end

	def Util.error_response(error)
		return response(false, {}, error.err_id, error.err_msg)
	end

end
