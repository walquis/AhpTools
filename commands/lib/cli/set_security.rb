require 'optparse'

module AhpTools
  module CLI
    class SetSecurity
      attr_reader :options

      def initialize()
        @options = {
          :resource_type => nil,
          :resource_name => nil,
          :role => nil,
          :action => nil,
          :remove => false,
          :no_exec => false,
        }
      end

      def execute(stdout, args=[])
        AhpTools::Commands::SetSecurityCommand.new(parse_options(args)).run
      end

      def parse_options(arguments=[])
        mandatory_options = %w( resource_type resource_name role action )

        parser = OptionParser.new do |opts|

          opts.banner = usage
          opts.separator ""
          opts.on("-a ACTION", "--action", "The action to set, e.g., read, write, use, security") { |o| @options[:action] = o.split(/,/) }
          opts.on("-n RES_NAME", "--resource_name", "The resource to set security on, e.g., 'sup-chirisk01' or 'all'") { |o| @options[:resource_name] = o.split(/,/) }
          opts.on("-r ROLE", "--role", "The name of the role for which security is being set, e.g., 'ProductionDeployer' ") { |o| @options[:role] = o.split(/,/) }
          opts.on("-t TYPE", "--resource_type", "The resource type on which to set security, e.g., 'env'") { |o| @options[:resource_type] = o.split(/,/) }
          opts.on("--remove") { |o| @options[:remove] = o }
          opts.on("--no_exec") { |o| @options[:no_exec] = o }
          opts.parse!(arguments)

          if mandatory_options && mandatory_options.find { |o| @options[o.to_sym].nil? }
            $stdout.puts opts; exit
          end

        end

        @options

      end

      def usage()
        return <<-BANNER.gsub(/^          /,'')

        NAME
          set_security - Set security attributes for Anthill Pro resources

        SYNOPSIS
          set_security [options]

        OPTIONS
          Option arguments tend to be regexes and/or comma-separated.

          [ --remove ] - By default, set_security will ADD the requested permission.

          [ --no_exec ] - Do everything as normal, but stop short of setting any security attributes.

          --resource_type type[,type,...] - Where type is one of the following:
              agent
              env - environment
              envgroup - environment group
              project
              folder
              libraryjob
              repository
              lifecyclemodel

          --role role[,role,...] - Operate on one or more of the roles defined in AHP, e.g., ProductionDeployer.

          --resource_name name[,name,...] - The option arg is either "all" or a case-insensitive regular
              expression.  The operation is applied to all resources whose names match the regex.  If "all" is specified,
              the security operation is applied to all resources of the indicated type(s).  I considered making "all" the
              default if --resource_name was not specified, but that would make it very easy to accidentally clobber a
              large number of permissions.

          --action action1[,action2,...] - One or more of "read", "use", "write", or "security".  Not all roles are relevant for all
              resources.  See the AHP Security Guide for details.

        NOTES
          In AHP, "Everyone" is just another role, as is "System Admin"--they have no special semantics.

        EXAMPLES

          Test-drive adding "read", "use", and "write" permission for "Everyone" to all agents, but don't actually do it.

              set_security --no_exec --resource_type agent --resource_name all --role Everyone --action read,use,write


          Remove read, write, and security permissions for "Build Master" from all library jobs (we don't use this role in AHP).

              set_security --resource_type libraryjob --resource_name all --role 'Build Master' --action security,read,write --remove

          Remove read/write from all folders for Observer, QA, ProductionDeployer, and SE roles

              set_security --resource_type folder --resource_name all --role Observer,QA,ProductionDeployer,SE --action read,write --remove

        CAVEATS
          Sometimes the operation fails with an "Error restoring object from database" exception, especially
          for "agent" resources, if a large number of instances are returned.  As a workaround, try selecting
          a smaller number of instances by restricting the resource_name regex.

        BANNER

      end

    end
  end
end
