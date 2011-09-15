module AhpTools
  module Commands
    class AddAgentsCommand < Base
      import "com.urbancode.anthill3.domain.agent"

      # include Helpers::EnvironmentHelper
      import "com.urbancode.anthill3.domain.servergroup"
      import "com.urbancode.anthill3.domain.agent"

      def run
        authenticated_uow do
          env = ServerGroupFactory::instance.restore_for_name(@options[:env])
          if env.nil?
            puts "Can't find environment: '" + @options[:env] + "'"
            return
          end

          @options[:agents].each do |a|
            a_obj = AgentFactory::instance.restore_for_name(a) # restore_for_name not case-sensitive, yay.
            if a_obj.nil?
              puts "Can't add agent '" + a + "' to environment '" + env.name + "'. Perhaps it doesn't exist, or perhaps you don't have permission for this environment."
              next
            end

            if env.contains_server(a_obj)
              puts "Already in env: " + a_obj.name
              next
            end
            env.add_server(a_obj)
          end
        end
      end
    end
  end
end

