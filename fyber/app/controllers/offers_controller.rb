class OffersController < ApplicationController
	def fetch
		@offers = fetch_offers(params[:offers])
		render :partial => 'offer_list', :locals => {:offers => @offers}
	end
end
