require 'optparse'
module AhpTools

  module CLI
    class AddStatusSteps

      def self.execute(stdout, arguments=[])
        options = {
          :job => "blah",
        }

        mandatory_options = %w( job )

        parser = OptionParser.new do |opts|

          opts.banner = <<-BANNER.gsub(/^          /,'')
            Options are:
          BANNER

          opts.separator ""
          opts.on("-j", "--job=JOB", String, "The job name - required") do |job|
            options[:job] = job
          end

          opts.parse!(arguments)

          if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
            stdout.puts opts; exit
          end
        end

        Commands::AddStatusStepsCommand.new(options).run
      end

    end

  end
end
