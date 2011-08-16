require 'optparse'

module AhpTools
  module CLI
    class NewEnvironments

      def self.execute(stdout, arguments=[])
        options = {
          :verbose => true,
          :environments => []
        }

        mandatory_options = %w( environments group )

        parser = OptionParser.new do |opts|

          opts.banner = <<-BANNER.gsub(/^          /,'')
            Will create the new environments specified, and the environment group (if it does not exist
            already). Environments will be added to the group.

            Usage: #{File.basename($0)} [options]

            Options are:
          BANNER

          opts.separator ""
          opts.on("-e ENVIRONMENT1,ENVIRONMENT2", Array, "The environments to create") { |environments| options[:environments] = environments }
          opts.on("-g ENVIRONMENT_GROUP", String, "The group to create or use") { |group| options[:group] = group }
          opts.parse!(arguments)

          if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
            stdout.puts opts; exit
          end
        end

        AhpTools::Commands::NewEnvironmentsCommand.new(options).run
      end

    end

  end
end
