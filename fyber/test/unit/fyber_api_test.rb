require 'test/unit'
require 'fyber'

class FyberApiTest < Test::Unit::TestCase
	include Fyber::API

	def test_should_return_error
		resp = fetch_offers({})
		assert_equal true, resp.instance_of?(Fyber::Error)
	end

	def test_should_return_400
		response = fetch_offers({pub0: 'campaign', page:1})
		assert_equal Fyber::Error, response.class
		assert_equal "Invalid request, please check the query parameters", response.message
	end

	def test_no_content_response
		response = fetch_offers({pub0: 'campaign', page: 1, uid: 'testRebyf'})
		assert_equal true, response.instance_of?(String)
		assert_equal "No content found", response
	end
end