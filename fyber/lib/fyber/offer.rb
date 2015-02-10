class Offer
	attr_reader :title, :payout, :thumbnail_url
	
	def initialize(data)
		@title     = data["title"]
		@payout   = data["payout"]
		@thumbnail_url = data["thumbnail"]["lowres"]
	end
end