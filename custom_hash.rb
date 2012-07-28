module CustomHash
	class HashPair
		attr_accessor :key, :value
		def initialize(key, value)
			@key = key
			@value = value
		end

		def to_s
			"#{@key} : #{@value}"
		end
	end
class InvalidInput < Exception; end
	#format of my hash is  ([key,valyue], [key,value])
	class MyHash
		include Enumerable
		def initialize(*value)
			@data = _parse_my_hash(value)
		end
	    
	    def data
	    	@data
	  	end  	

	  	def to_s
	  		return nil if @data.nil?
	  		@data.collect(&:to_s)
	  	end

		def has_key?(key)
			@data.collect(&:key).include?(key)
		end

		def each &block
			@data.each{|pair| block.call(pair)}
		end


		private 
		def _parse_my_hash(value)
			my_hash = []
			value.each do |pair| 
				p pair.class
				p pair.kind_of?(Array)
				raise InvalidInput if !pair.kind_of?(Array) || pair.length != 2
				my_hash << HashPair.new(pair.first, pair.last)
			end
			return my_hash
		end
	end
end