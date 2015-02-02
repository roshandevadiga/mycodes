# Author : Roshan Devadiga
# Assumptions : A valid phone number consists of only 9 digit number i.e 110015010 is valid , but 110-015-010 is not valid
#

module PhoneToString
	NUM_MAP = {
		'1' => ['1'],
		'2' => ['a', 'b', 'c'],
		'3' => ['d', 'e', 'f'],
		'4' => ['g', 'h', 'i'],
		'5' => ['j', 'k', 'l'],
		'6' => ['m', 'n', 'o'],
		'7' => ['p', 'q', 'r', 's'],
		'8' => ['t', 'u', 'v'],
		'9' => ['w', 'x', 'y', 'z'],
		'0' => ['0'],
	}

	def self.included(base)
		base.extend PhoneToString::ClassMethods
		base.send :include, PhoneToString::InstanceMethods
	end

	module ClassMethods
		def valid_length
			9 #default value if not overridden by the including class
		end
	end

	module InstanceMethods
		def valid_length
			self.class.valid_length
		end

		def to_easy_remember
			is_end = false
			phone_number = @number.split('')
			last_number  = phone_number.last
			stack = init_stack(phone_number, valid_length)

			while !is_end do
				print_all(stack, PhoneToString::NUM_MAP[last_number])
				stack = update_stack(stack)
				stack = fill_up(stack, phone_number)
				is_end = stack.nil?
			end
		end

		def print_all(stack, char_arr)
			pre_text = stack.collect(&:values).join('')
			char_arr.each do |chr|
				puts pre_text + chr
			end
		end

		def update_stack(stack)
			item = stack.pop
			return nil if item.nil? #All variation have been printed
			key = item.keys.first.to_s
			val = item.values.first

			next_index = NUM_MAP[item.keys.first.to_s].index(val) + 1
			if NUM_MAP[key].at(next_index)
				stack.push({key => NUM_MAP[key].at(next_index)})
			else
				stack = update_stack(stack)
			end
			return stack
		end

		def fill_up(stack, phone_number)
			return nil if stack.nil?
			nxt_index = stack.length - 1
			return stack if  nxt_index < 0 || (nxt_index >= (valid_length - 2))

			phone_number[(nxt_index+1)..(valid_length-2)].each do |key|
				stack.push({key => NUM_MAP[key].first})
			end
			return stack
		end

		def init_stack(phone_number, ph_length)
			stack = []
			phone_number[0..(ph_length-2)].each do |num|
				stack.push({num => NUM_MAP[num].first})
			end
			return stack
		end
	end
end

class Phone
	VALID_LENGTH = 9
	include PhoneToString

	def initialize(number)
		@number = number
		@stack  = [] #
	end

	def valid?
		return false if @number.size != Phone::VALID_LENGTH
		return false if @number.match(/(\A\d+\z)/).nil? #not a valid number
		return true
	end

	def self.valid_length
		VALID_LENGTH
	end
end

puts "Enter the phone number : "
input = gets.chomp.strip
phone = Phone.new(input)
puts "\nOUTPUT : \n\n"
phone.valid? ?  phone.to_easy_remember : puts("ERROR")