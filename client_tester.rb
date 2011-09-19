require 'net/http'
require 'uri'

@base_url = "http://thirdshift.dyndns.org:4567"

def post(url, post_params, basic_auth=nil)
	url = URI.parse(url)

    	req = Net::HTTP::Post.new(url.path)
	req.form_data = post_params
	resp = Net::HTTP.start(url.host, url.port) {|http|
		#req.basic_auth 'joshdholtz@gmail.com', 'test1'
		http.request(req)
	}

	return resp.body
end

def get(url)
	url = URI.parse(url)

    	req = Net::HTTP::Get.new(url.path)
	resp = Net::HTTP.start(url.host, url.port) {|http|
		req.basic_auth 'root', 'velenspeok0301'
		http.request(req)
	}

	return resp.body
end

def read_in(prompt)
	print "\n" + prompt + ": "
	std_in = gets
	return std_in.strip
end

def test()
	return get(@base_url + "/test")
end

def test_clean()
	return get(@base_url + "/test/clean")
end

def register_user(email, password)
	return post(@base_url + "/user/register",  {"email" => email, "password" => password} )
end

if __FILE__ == $0
	print "**TEST"
	puts test_clean()
	
	print "\n**REGISTER USER"
	puts register_user(read_in("Email"), read_in("Password"))
end
