require 'optparse'
module AhpTools
  module CLI
    class Deploy

      def self.execute(stdout, arguments=[])
        options = {
          :agents      => "",
          :buildlabel  => "latest",
          :username    => ENV['USER'] || ENV['USERNAME'],
          :timeout     => 30,
          :debug       => false,
          :status_only => false
        }
        mandatory_options = %w( project workflow environment buildlabel )

        parser = OptionParser.new do |opts|

          opts.banner = <<-BANNER.gsub(/^ {12}/,'')
            Kick off and return deploy status for a given project, workflow, and environment
            in an anthill pro buildlife.  Specify agents to which to deploy, or accept the
            default of all configured dynamic agents.  Specify a specific buildlabel/stamp,
            or it'll deploy the latest buildlabel/stamp.  Specify a user account from which
            to run the deploy.  The default is the currently logged in user.  By default,
            deploy will wait 30 seconds to finish - increase the timeout by specifying the
            --timeout argument and supplying an appropriate value.

            Usage: #{File.basename($0)} --project PROJECT --workflow WORKFLOW 
                       --environment ENVIRONMENT [--buildlabel BUILDLABEL] 
                       [--agents AGENT1,AGENT2] [--username USERNAME] 
                       [--timeout TIMEOUT] [--status_only] [--debug]

            Options are:
          BANNER

          opts.separator ""

          opts.on( "-b BUILDLABEL", "--buildlabel", "buildlife label to deploy (default: latest" ) do |buildlabel|
            options[:buildlabel] = buildlabel
          end # opts.on() do ||
          opts.on( "-p PROJECT", "--project", "Project in which the build label appears" ) do |project|
            options[:project] = project
          end # opts.on() do ||
          opts.on( "-w WORKFLOW", "--workflow", "Workflow to run" ) do |workflow|
            options[:workflow] = workflow
          end # opts.on() do ||
          opts.on( "-e ENVIRONMENT", "--environment", "Environment to which to deploy" ) do |environment|
            options[:environment] = environment
          end # opts.on() do ||
          opts.on( "-a AGENTS", "--agents", "Comma separated list of agents (default: all agents in environment)" ) do |agents|
            options[:agents] = agents
          end # opts.on() do ||
          opts.on( "-u USERNAME", "--username", "Username to run the deployment (default: currently logged in user)" ) do |username|
            options[:username] = username
          end # opts.on() do ||
          opts.on( "-t TIMEOUT", "--timeout", "Amount of time in seconds to wait for a status (default: 30s)" ) do |timeout|
            options[:timeout] = timeout
          end # opts.on() do ||
          opts.on( "-s", "--status_only", "Don't launch.  Instead, poll for status as if deployment is already launched." ) do |status_only|
            options[:status_only] = status_only
          end # opts.on() do ||
          opts.on( "-d", "--debug", "Turn on debugging output" ) do |debug|
            options[:debug] = debug
          end # opts.on() do ||

          opts.on_tail( "-h", "--help", "Show this message" ) do
            puts opts
            exit 0
          end # opts.on_tail do

          opts.parse!( arguments )

          if mandatory_options && mandatory_options.find { |o| options[o.to_sym].nil? }
            stdout.puts opts; exit
          end

          required_args = [:buildlabel, :project, :workflow]
          required_args << :environment if options[:status_only].nil?

          arguments = ""; count = 0
          required_args.each do |arg|
            next unless options[arg].nil?
            arguments += (arguments.eql?("") ? "":", ")  + "--#{arg}"
            count += 1
          end # required_args.each do |arg|

          if count > 0
            Deploy.print_missing_args_msg count, arguments, opts
            exit 255
          end # if count > 0

        end #  parser = OptionParser.new do |opts|

        Commands::DeployCommand.new( options ).run
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

    end # class Deploy
  end # module CLI
end # module AhpTools
