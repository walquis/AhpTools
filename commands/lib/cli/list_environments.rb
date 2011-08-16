require 'optparse'
module AhpTools

  module CLI
    class ListEnvironments

      def self.execute(stdout, arguments=[])
        options = {
          :agents => true,
          :query => "",
          :env => ""
        }

        parser = OptionParser.new do |opts|

          opts.banner = <<-BANNER.gsub(/^          /,'')
            List all environments and groups in anthill pro

            Usage: #{File.basename($0)} [options]

            Options are:
          BANNER

          opts.separator ""
          opts.on("-a", "--no-agents", "Show all the agents in an environment") { |agents| options[:agents] = agents }
          opts.on("-q", "--query=QUERY", String, "query on an environment group name") { |q| options[:query] = q }
          opts.on("-e", "--env=ENV", String, "query on an environment name") { |e| options[:env] = e }
          opts.parse!(arguments)

        end

        Commands::ListEnvironmentsCommand.new(options).run
      end

    end

  end
end
