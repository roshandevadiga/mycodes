require File.expand_path('my_hash.rb')
require File.expand_path('binary_add.rb')
require File.expand_path('fibo.rb')
include CustomHash


begin
	hash1 = MyHash.new([1,2], [2,3], [4,5])
	hash1.each do  |value|
		puts value 
	end	
rescue Exception => e
	puts 'Invalid input type'
end




puts 'Please enter a the length of fibonacci series'
begin
	fib = Fibonacci.new(gets.chomp)
	fib.display_series
rescue  InvalidInput => e
	puts "\n\nWonly numbers !!"
end


begin 
	puts 'Please enter a binary number: '
	first_no = Binary.new(gets.chomp)
	puts 'Enter the second Binary number'
	second_no = Binary.new(gets.chomp)
	puts first_no + second_no
rescue InvalidBinary => e
	p e.msg
 end