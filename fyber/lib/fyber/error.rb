module Fyber
	class Error
		attr_reader :message
		def initialize(err)
			@message = err
		end

		def self.find_all(response)
			return case response.code.to_s
			when '200'
				new("Invalid reponse recieved from server, please try again")
			when '401'
				new("You are not authorized to view the offers")
			when '400'
				new("Invalid request, please check the query parameters")
			else
				new("Opps!! Something went wrong, please try again later")
			end
		end
	end
end