class  InvalidInput < Exception; end
class Fibonacci
	def initialize (value = 0)
		@number = _validate(value)
	end 

	def series(&block)
		prev = 0
		nex = 1
		series = []
		(@number + 1).times do 
			block_given? ? (yield block.call(prev)): series << prev 
			old_prev = prev
			prev = nex
			nex = old_prev + nex
		end
		series
	end

	def display_series
		series{|value| puts value}
	end

	private 
	def _validate (value)
		return 0 if value.nil?
		/(\D)+/.match(value)
		raise InvalidInput unless $1.nil?
		value.to_i
	end
end