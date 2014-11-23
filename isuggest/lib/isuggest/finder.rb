module Isuggest
	module Finder
		def self.included(base)
			base.extend ClassMethods
			base.include InstanceMethods
		end

	end

	module ClassMethods

	end

	module InstanceMethods
		def is_unique?
			column_name = isuggest_columns.first.to_sym
			return !self.class.exists?(column_name => self.send(column_name))
		end

		def suggestions
			me_suggests = []
			number = 10
			while me_suggests.length < self.class.isuggest_options[:total_suggestions].to_i
				me_suggests = filter_suggestions(me_suggests, number)
				number = number * 10
			end
			return me_suggests
		end

		def filter_suggestions(me_suggests, number)
			column_name = isuggest_columns.first
			base_value = self.send(column_name)
			while(me_suggests.length < 6) do
				 me_suggests << "#{base_value}#{self.class.isuggest_options[:seperator]}#{rand(number)}"
				 me_suggests.uniq!
			end
			results = self.class.where(["#{column_name} in (#{me_suggests.map{|s| '"'+s+'"'}.join(',')})"]).select(column_name).collect(&:"#{column_name}")
			
			return (results.length == 0) ? me_suggests : (me_suggests - results)
		end

		def isuggest_columns
			return self.class.isuggest_options[:on]
		end
	end
end
