require 'error'
require 'util'

module Route
	module Website

		get '/' do
			if session.key?("id")
				redirect "/dashboard"
			end

			@page = "index"
			erb :index
		end

		get '/features' do
			@page = "features"
			erb :features
		end

		get '/starthere' do
			@page = "starthere"
			erb :starthere
		end

		get '/doc' do
			@page = "doc"
			erb :doc
		end

		get '/faq' do
			@page = "faq"
			erb :faq
		end

		get '/about' do
			@page = "about"
			erb :about
		end

	end
end
