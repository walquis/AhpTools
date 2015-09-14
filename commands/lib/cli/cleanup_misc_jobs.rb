require 'optparse'
module AhpTools
  module CLI
    class CleanupMiscJobs

      def self.execute(stdout, arguments=[])
        options = { :exec => true }

        parser = OptionParser.new do |opts|

          opts.banner = <<-BANNER.gsub(/^ {12}/,'')
            Delete miscellaneous jobs in all projects.
            Usage: #{File.basename($0)} [ --[no-]exec ]
            Options are:
          BANNER

          opts.separator ""

          opts.on( "-e ", "--[no-]exec", "If 'no-' prepended, just list the misc-job count for each project" ) do |e|
            options[:exec] = e  # If 'no-' prepended, e is false regardless of the option value, otherwise it's whatever the option value is, or true if no option value supplied).
            if e=='false' || e=='no' || e=='0' # Accommodate uninformed values of exec that would seem to make sense
              options[:exec] = false
            end
          end

          opts.on_tail( "-h", "--help", "Show this message" ) do
            puts opts
            exit 0
          end # opts.on_tail do

          opts.parse!( arguments )

        end #  parser = OptionParser.new do |opts|

        Commands::CleanupMiscJobsCommand.new( options ).run
      end # def self.execute

    end # class CleanupMiscJobs
  end # module CLI
end # module AhpTools
