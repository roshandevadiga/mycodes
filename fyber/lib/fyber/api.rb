require 'net/http'
require 'digest/sha1'

module Fyber
	module API
		API_KEY = "b07a12df7d52e6c118e5d47d3f9e60135b109a1f"
		OFFER_URL = "http://api.sponsorpay.com/feed/v1/offers.json"

		def fetch_offers(options)
			options["timestamp"] = Time.now.to_i

			qry = default_options.merge(options)
			qry.delete(:hashkey)
			qry[:hashkey] = signed(form_query(qry) + "&#{API_KEY}")
			uri = URI("#{OFFER_URL}?#{form_query(qry)}")
			response = Net::HTTP.get_response(uri)

			return format_reponse(response)
		end

		def default_options
			HashWithIndifferentAccess.new({
							:appid 	     => 157,
							:device_id   => '2b6f0cc904d137be2e1730235f5664094b831186',
							:format      => 'json' ,
							:hashkey     => '',
							:ip          => '109.235.143.113',
							:locale      => 'de',
							:offer_types => 100,
							:page        => 1,
							:pub0		 		 => '',
							:timestamp   => 1234
						})
		end

		def signed(data)
			Digest::SHA1.hexdigest(data)
		end

		def form_query(data)
			data = data.sort.to_h
			query_str = data.map{|k, v| "#{k.to_s}=#{v}"}.join('&')
		end

		def create_obj(resp)
			resp = JSON.parse(resp.body)
			# resp["offers"] = [{"title" => "offer1", "payout" => 123, "thumbnail" => {"lowres" => "http://www.online-image-editor.com/styles/2014/images/example_image.png"}}]
			# resp["code"] = '200'
			offers = resp["offers"].map{|offer| Offer.new(offer)}
			offers = "No content found" if resp["code"] == "NO_CONTENT"
			return offers
		end

		def format_reponse(response)
			if response.code.to_s == '200' && response_valid?(response)
				return create_obj(response)
			else
				return Fyber::Error.find_all(response)
			end
		end

		def response_valid?(response)
			signature = response.to_hash["x-sponsorpay-response-signature"]
			return true if signature.blank?
			signed(response.body + API_KEY) == signature.first
		end
	end
end