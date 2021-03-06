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
		status = stack_exist?(index)
		return status if status.is_a?(MyError)
		STACKS[index] << item
	end

	def pop(index, options = {})
		status = stack_exist?(index)
		return status if status.is_a?(MyError)
    	STACKS[index].data.length > 0 ? STACKS[index].data.pop.to_i : MyError.new('error: stack is empty')
	end

	def delete_s(index, options = {})
		status = stack_exist?(index)
		return status if status.is_a?(MyError)
		STACKS[index] = nil
	end

	def print_s(index, options = {})
		status = stack_exist?(index)
		return status if status.is_a?(MyError)
		return STACKS[index].blank? ? 'empty' : STACKS[index].data.join(' ')
	end

	def stack_exist?(index, options = {})
		MyError.new('Please create a stack first') unless STACKS[index].is_a?(MyStack)
	end
end

module QueueOperation
	QUEUES = []
	def new_q (index, options = {})
		QUEUES[index].nil? ? QUEUES[index] = MyQueue.new : raise('There is already a Queue at this location')
	end

	def enqueue(index, item)
		raise ArgumentError, "Data to be stored in the Queue should be in range ot 0 to 1000" if(item.to_i > 1000 || item.to_i < 0)
		status = queue_exist?(index)
		return status if status.is_a?(MyError)
		QUEUES[index] << item
	end

	def dequeue(index, options = {})
		status = queue_exist?(index)
		return status if status.is_a?(MyError)
		QUEUES[index].data.length > 0 ? QUEUES[index].data.shift.to_i : MyError.new('error: queue is empty')
	end

	def delete_q(index, options = {})
		status = queue_exist?(index)
		return status if status.is_a?(MyError)
		QUEUES[index] = nil
	end

	def print_q(index, options = {})
		status = queue_exist?(index)
		return status if status.is_a?(MyError)
		return QUEUES[index].blank? ? 'empty' : QUEUES[index].data.reverse.join(' ')
	end

	def queue_exist?(index, options = {})
		MyError.new('Please create a queue first') unless QUEUES[index].is_a?(MyQueue)
	end
end

module DataTransfer
	def stack2stack(src, dest)
		return MyError.new('error: wrong command') if STACKS[src].blank? || STACKS[dest].full?
		item = pop(src)
		item.is_a?(MyError) ? item : push(dest, item) 
	end

	def stack2queue(src, dest)
		return MyError.new('error: wrong command') if STACKS[src].blank? || QUEUES[dest].full?
		item = pop(src)
		item.is_a?(MyError) ? item : enqueue(dest, item) 
	end

	def queue2stack(src, dest)
		return MyError.new('error: wrong command') if STACKS[src].blank? || QUEUES[dest].full?
		item = dequeue(src)
		item.is_a?(MyError) ? item : push(dest, item) 
	end

	def queue2queue(src, dest)
		return MyError.new('error: wrong command') if QUEUES[src].blank? || QUEUES[dest].full?
		item = dequeue(src)
		item.is_a?(MyError) ? item : enqueue(dest, item) 
	end
end


include StackOperation
include QueueOperation
include DataTransfer

results = []
begin
	puts 'Input:'
	command_map = {
		'stack->stack' => 'stack2stack',
		'stack->queue' => 'stack2queue',
		'queue->stack' => 'queue2stack',
		'queue->queue' => 'queue2queue',
		'new_s'  => 'new_s',
		'push'   => 'push',
		'pop'    => 'pop',
		'new_q'  => 'new_q',
		'enqueue'  => 'enqueue',
		'dequeue'  => 'dequeue',
		'print_q'  => 'print_q',
		'print_s'  => 'print_s',
		'delete_s' => 'delete_s',
		'delete_q' => 'delete_q'
	}

	while command = gets.chomp.strip do
		if command == '' || command.empty?
			puts 'Output:'
			results.each{|item| puts item}
			break
		else
			command = command.split(/\s/)
			output = if command[1].nil? || command[1].empty?
				MyError.new('error : invalid command') 
			else
				eval("#{command_map[command[0]]}(#{command[1]}, #{command[2] || {} })")
			end
			if ['print_s', 'print_q'].include?(command[0]) || output.is_a?(MyError)
				results << (output.is_a?(MyError) ? output.msg : output)
			end
		end
	end
rescue Exception => e
	puts e.message
end

