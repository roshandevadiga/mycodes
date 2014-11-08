# Equation consists of characters '+', '-', 'x', '=' and integers. 
# Characters '+' and '=' never occur at the beginning nor at the end of the equation, the sign '-' is never placed at the end of the 
# equation, two identical characters can't be put together (pairs '-','+' and '=','+' as well).

# Input
# The first line of the input contains number of tests t (t≤5000). Each test consists of a single line with equation 
# which doesn't contain any spaces. Length of the equation doesn't exceed 1000 characters.

# Output
# For each test print the solution of the given equation (the solution is always an integer) or NO if the equation doesn't have 
# exactly one solution.

# Input:
# 2
# 24-x+3x-2x=16-x
# 16-4x+2x-12=-2x+10
# Output:
# -8
# NO

class InvalidTestSizeError < StandardError; end
class EquationInvalidError < StandardError; end
class InvalidInputSize < StandardError; end

class Equation
	def initialize(input)
		@equ =  input
    @solution = nil
  end

  def validate
    raise InvalidInputSize     if @equ.length > 1000
    raise EquationInvalidError if !syntax_valid?
  end

  def solve
    validate
    equ_parts = @equ.split('=')
    lhs = equ_parts.first
    rhs = equ_parts.last
    variable = variable_part(lhs, rhs)
    constant = variable.zero? ? nil : constant_part(rhs, lhs)

    @solution = constant.fdiv(variable).round(3) if !variable.zero?
    @solution = 0 if !@solution.nil? && @solution.zero? #ignore sign -ve / +ve
  end

  def display
    puts(@solution.nil? ? 'NO' : @solution)
  end

  private 
  def syntax_valid?
    return (first_char_valid? && last_char_valid? && signs_valid?)
  end

  def first_char_valid?
    !['+', '='].include?(@equ[0])
  end

  def last_char_valid?
    !['-','+', '='].include?(@equ[@equ.length - 1])
  end

  def signs_valid?
    @equ.scan(/(xx|\s|--|\+\+|==|\+=)/).length == 0
  end

  def constant_part(rhs, lhs)
    regex = /(\+[0-9]+|-[0-9]+|[0-9]+)/
    variable_regex = /(\+[0-9]+|-[0-9]+|[0-9]+)x/
    lhs_part = lhs.scan(regex).flatten.uniq - lhs.scan(variable_regex).flatten.uniq 
    rhs_part = rhs.scan(regex).flatten.uniq - rhs.scan(variable_regex).flatten.uniq 

    return (sum(rhs_part) - sum(lhs_part))
  end

  def variable_part(lhs, rhs)
    regex = /([0-9]*|\+[0-9]*|-[0-9]*)x/
    lhs_part = lhs.scan(regex).flatten.map{|item| item.empty? ? '1' : item}
    rhs_part = rhs.scan(regex).flatten.map{|item| item.empty? ? '1' : item}
    
    return ( sum(lhs_part) - sum(rhs_part) )
  end

  def sum(val)
    return val.collect(&:to_i).inject(&:+) || 0
  end
end

begin
  no_of_test = gets.chomp.to_i
  raise InvalidTestSizeError if no_of_test > 5000

  equations = []
  no_of_test.times do
    equations << Equation.new(gets.chomp)
  end

  for itr in 0..(no_of_test - 1) do
    equations[itr].solve
    equations[itr].display
  end  
rescue InvalidInputSize => e
  puts 'Input size should be less than 5000 characters'
rescue EquationInvalidError => e
  puts 'Equation is not valid, please check the defined rules'
rescue InvalidTestSizeError => e
  puts 'Number of tests should be less than 1000'
end
