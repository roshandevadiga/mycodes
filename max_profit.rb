#Author : Roshan Devadiga
#ASSUMPTION :
# -  Input feeded to the program is always correct
# -  Only positive profit is considered real profit

module PlotOperations
	def max_profit(plots, plot_count)
		current_sum = 0
		profit_max = 0
		start_plot = 1
		end_plot = 1
		temp_pt = 1

		if (plot_count == 1)
			profit = plots.first.to_i
			puts display(1,1, profit)
			return [1, 1, profit]
		end

		for itr in 0..(plot_count-1) do
			temp_pt = itr + 1 if(plots[itr].to_i >= 0 && current_sum <= 0) # To decide the start point 
			current_sum = current_sum + plots[itr].to_i
			if(profit_max < current_sum)
				start_plot = (profit_max.zero?) ? end_plot : temp_pt
				end_plot   = itr + 1
				profit_max = current_sum
			elsif profit_max == current_sum && (end_plot - start_plot) > ((itr + 1) - temp_pt)
				start_plot = temp_pt
				end_plot   = itr + 1
			elsif current_sum < 0
				current_sum = 0
			end
		end
		puts display(start_plot, end_plot, profit_max)
		return [start_plot, end_plot, profit_max]
	end

	def display(start_plot, end_plot, profit)
		if(profit > 0)
			return "#{start_plot} #{end_plot} #{profit}"
		else
			return 'Opps !! No plot is profitable !'
		end
	end
end

include PlotOperations

puts " Enter the number of plots"
plot_count = gets.chomp.to_i

puts "Enter the Profits for each plot seperated by space"
plots = gets.chomp.strip.split(/\s+/)

PlotOperations::max_profit(plots, plot_count).join(' ')