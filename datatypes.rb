require 'pry'

class DataObject
	attr_accessor :data
	LIMIT = 10
	def initialize
		@data = []
	end

  def <<(item)
		data << item
	end

	def blank?
		data.length == 0
	end

	def full?
		data.length == LIMIT
	end
end

class MyStack < DataObject
	def <<(item)
		full? ? MyError.new('error: stack is full') : super
	end
end

class MyQueue < DataObject
	def <<(item)
		full? ? MyError.new('error: queue is full')  : super
	end
end

class MyError
	attr_accessor :msg
	def initialize(msg)
		@msg = msg
	end
end

module StackOperation
	STACKS = []
	def new_s(index, options = {})
		STACKS[index].nil? ? STACKS[index] = MyStack.new : raise('There is already a stack at this location')
	end

	def push(index, item)
		raise ArgumentError, "Data to be stored in the stack should be in range ot 0 to 1000" if(item.to_i > 1000 || item.to_i < 0)
		stack_exist?(index)
		STACKS[index] << item
	end

	def pop(index, options = {})
		stack_exist?(index)
    STACKS[index].data.length > 0 ? STACKS[index].data.delete(STACKS[index].data.last).to_i : MyError.new('error: stack is empty')
	end

	def delete_s(index, options = {})
		stack_exist?(index)
		STACKS[index] = nil
	end

	def print_s(index, options = {})
		stack_exist?(index)
		return STACKS[index].blank? ? 'Stack is empty' : STACKS[index].data.join(' ')
	end

	def stack_exist?(index, options = {})
		raise 'Please create a stack first' unless STACKS[index].is_a?(MyStack)
	end
end

module QueueOperation
	QUEUES = []
	def new_q (index, options = {})
		QUEUES[index].nil? ? QUEUES[index] = MyQueue.new : raise('There is already a Queue at this location')
	end

	def enqueue(index, item)
		raise ArgumentError, "Data to be stored in the Queue should be in range ot 0 to 1000" if(item.to_i > 1000 || item.to_i < 0)
		queue_exist?(index)
		QUEUES[index] << item
	end

	def dequeue(index, options = {})
		queue_exist?(index)
		QUEUES[index].data.length > 0 ? QUEUES[index].data.shift.to_i : MyError.new('error: queue is empty')
	end

	def delete_q(index, options = {})
		queue_exist?(index)
		QUEUES[index] = nil
	end

	def print_q(index, options = {})
		queue_exist?(index)
		return QUEUES[index].blank? ? 'queue is empty' : QUEUES[index].data.join(' ')
	end

	def queue_exist?(index, options = {})
		raise 'Please create a queue first' unless QUEUES[index].is_a?(MyQueue)
	end
end

module DataTransfer
	def stack2stack(src, dest)
		return MyError.new('error: wrong command') if STACKS[src].blank? || STACKS[dest].full?
		push(dest, pop(src))
	end

	def stack2queue(src, dest)
		return MyError.new('error: wrong command') if STACKS[src].blank? || QUEUES[dest].full?
		enqueue(dest, pop(src)) 
	end

	def queue2stack(src, dest)
		return MyError.new('error: wrong command') if STACKS[src].blank? || QUEUES[dest].full?
		push(dest, dequeue(src))
	end

	def queue2queue(src, dest)
		return MyError.new('error: wrong command') if STACKS[src].blank? || QUEUES[dest].full?
		enqueue(dest, dequeue(src))
	end
end


include StackOperation
include QueueOperation
include DataTransfer

results = []
begin

	while(true) do
		command = gets.chomp.strip
		if command == ''
			results.each{|item| puts item}
			break
		else
			command = command.split(/\s/)
			output = eval("#{command[0]}(#{command[1]}, #{command[2] })")
			if ['print_s', 'print_q'].include?(command[0]) || output.is_a?(MyError)
				results << (output.is_a?(MyError) ? output.msg : output)
			end
		end
	end
rescue Exception => e
	puts e.message
end


=begin
	
 	Write a program implementing event handlers associated with operations executed on stacks and queues. Every line in the input is a distinct command. Every command informs about a type of operation and about index (from range 0..9) of stack or queue on which the operation should be executed. Each stack and queue may contain at most 10 elements (which are numbers from range 0..1000). At the beginning no stacks or queues are present.
Events that should be handled:

    creating new (empty) stack with index i
    new_s i
    adding new element e to the stack with index i
    push i e
    Note: in case the stack is full you should print: "error: stack is full".
    removing element from the top of the stack with index i
    pop i
    Note: in case the stack is empty you should print: "error: stack is empty".
    deleting the whole stack (with all it's elements) with index i
    delete_s i
    printing contents from stack with index i (in one line, separated by spaces; if there are no elements you should print "empty")
    print_s i
    creating a new queue with index i
    new_q i
    adding an element at the end of the queue with index i
    enqueue i e
    Note: in case the queue is full you should print: "error: queue is full".
    removing element from the front of the queue with index i
    dequeue i
    Note: in case the queue is empty you should print: "error: queue is empty".
    deleting queue with index i with all it's elements
    delete_q i
    printing contents from queue with index i (in one line, separated by spaces, starting from the end of the queue; if there are no elements you should print "empty")
    print_q i
    moving element from the top of stack with index i to the stack with index j
    stack->stack i j
    moving element from stack with index i to the queue with index j
    stack->queue i j
    moving element from queue with index i to the queue with index j
    queue->queue i j
    moving element from queue with index i to the stack with index j
    queue->stack i j
    in the above 4 cases you should print: "error: wrong command" in case of adding element to a full container or removing it from an empty container

Example 1

Input:

new_s 0
push 0 96
new_s 5
print_s 5
push 5 28
push 5 99
push 5 88
pop 0
print_s 5
push 0 65
stack->stack 5 0
print_s 0



Output:

empty
28 99 88
65 88

Example 2

Input:

new_s 0
push 0 96
new_s 5
print_s 5
push 5 28
push 5 99
push 5 33
push 5 88
pop 0
print_s 5
pop 0
push 0 65
push 5 99
push 5 13
push 5 99
push 5 1
push 5 99
push 5 0
push 5 9
push 5 87
stack->stack 5 0
print_s 0



Output:

empty
28 99 33 88
error: stack is empty
error: stack is full
error: stack is full
65 0

Example 3

Input:

new_s 0
push 0 96
new_s 5
print_s 5
push 5 28
push 5 99
new_q 0
push 5 33
push 5 88
pop 0
print_s 5
pop 0
push 0 65
push 5 99
dequeue 0
enqueue 0 4
new_q 9
push 5 13
push 5 99
enqueue 0 43
enqueue 0 21
enqueue 0 17
enqueue 0 4
enqueue 9 0
enqueue 0 4
enqueue 0 43
enqueue 0 40
push 5 1
push 5 99
enqueue 0 33
enqueue 0 99
enqueue 0 8
push 5 0
push 5 9
delete_q 0
print_q 9
push 5 87
new_q 0
enqueue 0 19
print_q 0
stack->stack 5 0
print_s 0



Output:

empty
28 99 33 88
error: stack is empty
error: queue is empty
error: queue is full
error: stack is full
0
error: stack is full
19
65 0

Example 4

Input:

new_s 0
push 0 96
new_s 5
print_s 5
push 5 28
push 5 99
new_q 0
push 5 33
push 5 88
pop 0
print_s 5
pop 0
push 0 65
push 5 99
dequeue 0
enqueue 0 4
new_q 9
push 5 13
push 5 99
enqueue 0 43
enqueue 0 21
enqueue 0 17
stack->queue 0 0
enqueue 0 4
stack->queue 0 0
enqueue 9 0
enqueue 0 4
enqueue 0 43
queue->queue 0 0
stack->stack 5 5
enqueue 0 40
push 5 1
push 5 99
enqueue 0 33
enqueue 0 99
enqueue 0 8
push 5 0
push 5 9
delete_q 0
print_q 9
push 5 87
new_q 0
stack->queue 5 0
enqueue 0 3
queue->queue 0 0
enqueue 0 19
stack->stack 5 0
print_s 0
print_s 5
print_q 0
print_q 9



Output:

empty
28 99 33 88
error: stack is empty
error: queue is empty
error: wrong command
error: queue is full
error: queue is full
error: stack is full
0
error: stack is full
99
28 99 33 88 99 13 99 1
19 0 3
0

	
=end