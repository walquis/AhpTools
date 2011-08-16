module AhpTools
  module Commands

    class SetSecurityCommand < Base

      include Helpers::SecurityHelper

      def run
				if @options[:no_exec]
					print "no_exec set, not going to do anything\n"
				end
				@options[:role].each do |role_name|
					@options[:resource_type].each do |resource_type_name|
						@options[:resource_name].each do |resource_name_filter|
							@options[:action].each do |action_name|
								authenticated_uow do |uow|
									SecuritySetter.new(role_name,resource_type_name,resource_name_filter,action_name,@options[:remove],@options[:no_exec]).set_security
								end
							end
						end
					end
				end
				if @options[:no_exec]
					print "no_exec set, didn't do anything\n"
				end

      end
    end
  end
end
