require 'optparse'
module AhpTools

  module CLI
    class AddAgents

      def self.execute(stdout, arguments=[])
        options = {
          :agents => "",
          :env => ""
        }

        parser = OptionParser.new do |opts|

          opts.banner = <<-BANNER.gsub(/^          /,'')
            Add one or more agents to an environment in anthill pro

            Usage: #{File.basename($0)} [options]

            Options are:
          BANNER

          opts.separator ""
          opts.on("-a AGENTS", "--agents", "the agents to be added to an environment") { |a| options[:agents] = a.split(/[:,]/)  }
          opts.on("-e ENV", "--env", "environment to which one or more agents will be added") { |env| options[:env] = env }
          opts.parse!(arguments)

        end

        Commands::AddAgentsCommand.new(options).run
      end

    end

  end
end

