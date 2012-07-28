class InvalidBinary < Exception
	def msg 
		"this is not a valid Binary"
	end
end

class Binary
	attr_accessor :number
	def initialize (b_number)
		@number = _validate(b_number)	
	end

	def +(second_number)
		max_size = (self.size > second_number.size) ?  self.size : second_number.size
		result = []
		carry = 0
		while (max_size != -1) do
			max_size -= 1
			if max_size == -1 #handle the condition when   LSB  additions carry is 1
				addition = 1
			else
				addition, carry = _add(self[max_size], second_number[max_size], carry)
			end
			result[max_size] =  addition
		end
		result.unshift(1) if carry == 1
		result.join('')
	end

	def size
		@number.size
	end

	def [](index)
		@number[index]
	end

	private 
	def _add(first, second, carry)
		count = _count_ones(first, second, carry)
		case count
		when 0
			return 0, 0
		when 1
			return 1, 0
		when 2
			return 0, 1
		when 3
			return 1,1
		else
			return 0,0
		end
	end

	def _count_ones(first, second, third)
		count = 0
		count += 1 if first.to_i ==  1
		count += 1 if second.to_i ==  1
		count += 1 if third.to_i ==  1
		count
	end

	def _validate(b_number)
		/([^0|^1])/.match(b_number)
		puts $1
		raise InvalidBinary if  b_number.nil? || !$1.nil?
		return  b_number.to_s
	end
end	



