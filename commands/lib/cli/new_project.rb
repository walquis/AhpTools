require 'optparse'
module AhpTools

  module CLI
    class NewProject

      def self.execute(stdout, arguments=[])
        options = {
          :quiet => false,
          :repository => "Dummy filesystem repo",
          :life_cycle_model => "Example Life-Cycle Model",
          :stamp_style => "teamCity",
          :artifact_set => "all",
          :artifact_base_dir => "dist",
          :platform => "linux"
        }

        mandatory_options = %w( project )

        parser = OptionParser.new do |opts|

          opts.banner = <<-BANNER.gsub(/^          /,'')
            AhpTools: deployment in disguise...

            Usage: #{File.basename($0)} [options]

            Options are:
          BANNER

          opts.separator ""
          opts.on("-p", "--project=PROJECT", String, "The project name - required") do |project|
            options[:project] = project
          end

          opts.on("-l", "--platform=PLATFORM", String, "The platform - used to pick library jobs", "Default: linux. 'win' is the other option.") do |platform|
            options[:platform] = platform
          end

          opts.on("-q", "--quiet", "Run silently", "Default: false") do |v|
            options[:quiet] = v
          end

          opts.on("-r", "--repository=[REPOSITORY]", String, "The name of the repository to use", "Default: Dummy filesystem repo") do |arg|
            options[:repository] = arg
          end

          opts.on("-m", "--life_cycle_model=[LIFE_CYCLE_MODEL]", String, "The lifecycle model to use for the project", "Default: Example Life-Cycle Model") do |arg|
            options[:life_cycle_model] = arg
          end

          opts.on("-s", "--stamp_style=[STAMP_STYLE]", String, "The stamp style to use", "Default: teamCity") do |arg|
            options[:stamp_style] = arg
          end

          opts.on("-a", "--artifact_set=[ARTIFACT_SET]", String, "The artifact set to use", "Default: all") do |arg|
            options[:artifact_set] = arg
          end

          opts.on("-b", "--artifact_base_dir=[ARTIFACT_BASE_DIR]", String, "Base dir to use for artifacts", "Default: dist") do |arg|
            options[:artifact_base_dir] = arg
          end

          opts.parse!(arguments)

          if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
            stdout.puts opts; exit
          end
        end

        Commands::NewProjectCommand.new(options).run
      end

    end

  end
end
