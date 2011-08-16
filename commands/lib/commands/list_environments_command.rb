module AhpTools

  module Commands

    class ListEnvironmentsCommand < Base

      import "com.urbancode.anthill3.domain.agent"

      include Helpers::EnvironmentHelper

      def run
        agent_cache = {}
        authenticated_uow do
          find_environment_groups.each do |environment_group|
            next unless matches_envgroup_query?(environment_group.name)
            $stdout.puts environment_group.name
            draw_line

            environment_group.server_group_array.each do |environment|
							next unless matches_env_query?(environment.name)
              $stdout.puts "\t" + environment.name
              if @options[:agents]
                names = []
                environment.server_array.each do |end_point|
                  if agent_cache.has_key?(end_point)
                    name = agent_cache[end_point]
                  else
                    name = AgentFactory::instance.restore_by_endpoint(end_point).name
                    agent_cache[end_point] = name
                  end
                  names << name
                end

                names.map { |n| n.downcase }.sort.each { |name| $stdout.puts "\t\t" + name }
                #$stdout.puts ""
              end
            end
            #draw_line
          end
        end
      end

      def draw_line
        $stdout.puts "----------------------------------------"
      end

      def matches_envgroup_query?(name)
        @options[:query].nil? || name =~ /#{@options[:query]}/i
      end

      def matches_env_query?(name)
        @options[:env].nil? || name =~ /#{@options[:env]}/i
      end

    end

  end

end
