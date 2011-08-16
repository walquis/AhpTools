module AhpTools
  module Commands

    class SetPropertyCommand < Base

      include Helpers::PropertyHelper

      def run
				@options[:no_exec] and print "no_exec set, not going to do anything\n"
				@options[:resource_type].each do |resource_type_name|
					@options[:resource_name].each do |resource_name_filter|
						authenticated_uow do |uow|
							PropertySetter.new(@options[:key],@options[:value],resource_type_name,resource_name_filter,@options[:remove],@options[:no_exec],@options[:append],@options[:append_delimiter]).set_property
						end
					end
				end
				@options[:no_exec] and print "no_exec set, didn't do anything\n"
      end
    end
  end
end
