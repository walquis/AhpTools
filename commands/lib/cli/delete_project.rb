require 'optparse'
module AhpTools
  module CLI
    class DeleteProject

      def self.execute(stdout, arguments=[])
        options = {}
        mandatory_options = %w( project )

        parser = OptionParser.new do |opts|

          opts.banner = <<-BANNER.gsub(/^ {12}/,'')
            Delete a project, including its miscellaneous jobs.
            Usage: #{File.basename($0)} --project PROJECT 
            Options are:
          BANNER

          opts.separator ""

          opts.on( "-p PROJECT", "--project", "Project in which the build label appears" ) do |project|
            options[:project] = project
          end # opts.on() do ||

          opts.on_tail( "-h", "--help", "Show this message" ) do
            puts opts
            exit 0
          end # opts.on_tail do

          opts.parse!( arguments )

          if mandatory_options && mandatory_options.find { |o| options[o.to_sym].nil? }
            stdout.puts opts; exit
          end

          required_args = [:project]

          arguments = ""; count = 0
          required_args.each do |arg|
            next unless options[arg].nil?
            arguments += (arguments.eql?("") ? "":", ")  + "--#{arg}"
            count += 1
          end # required_args.each do |arg|

          if count > 0
            DeleteProject.print_missing_args_msg count, arguments, opts
            exit 255
          end # if count > 0

        end #  parser = OptionParser.new do |opts|

        Commands::DeleteProjectCommand.new( options ).run
      end # def self.execute

      def self.print_missing_args_msg count, arguments, opts
        label = "argument" + (count > 1 ? "s" : "")
        verb = count > 1 ? "are" : "is"
        if count > 2
          arguments.reverse!.sub!( /,/, 'dna ,' ).reverse!
        elsif count > 1
          arguments.reverse!.sub!( /,/, 'dna ' ).reverse!
        end # if count > 2
        puts "ERROR: The #{label} #{arguments} #{verb} required"
        puts
        puts opts
      end # def self.print_missing_args_msg

    end # class DeleteProject
  end # module CLI
end # module AhpTools
