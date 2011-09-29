require 'error'
require 'util'

module Route
	module Website

		get '/' do
			if session.key?("id")
				redirect "/dashboard"
			end

			erb :index
		end


	end
end
