require 'optparse'

module AhpTools
  module CLI
    class SetProperty
      attr_reader :options

      def initialize()
        @options = {
          :resource_type => nil,
          :resource_name => nil,
          :key => nil,
          :value => nil,
          :remove => false,
          :no_exec => false,
					:append => false,
					:append_delimiter => ' '
        }
      end

      def execute(stdout, args=[])
        AhpTools::Commands::SetPropertyCommand.new(parse_options(args)).run
      end

      def parse_options(arguments=[])
        mandatory_options = %w( resource_type resource_name key )

        parser = OptionParser.new do |opts|

          opts.banner = usage
          opts.separator ""
          opts.on("-k KEY", "--key", "The name of the property to set") { |o| @options[:key] = o }
          opts.on("-v VALUE", "--value", "The value of the property") { |o| @options[:value] = o }
          opts.on("-n RES_NAME", "--resource_name", "The resource on which to set the property, e.g., 'sup-chirisk01' or 'all'") { |o| @options[:resource_name] = o.split(/,/) }
          opts.on("-t TYPE", "--resource_type", "The resource type on which to set a property, e.g., 'workflow' or 'project' or 'agent' or 'env' ") { |o| @options[:resource_type] = o.split(/,/) }
          opts.on("--remove")  { |o| @options[:remove]  = o }
          opts.on("--no_exec") { |o| @options[:no_exec] = o }
          opts.on("--append")  { |o| @options[:append]  = o }
          opts.on("--append_delimiter DELIMITER", "--append_delimiter", "The delimiter to use, or 'none'.  Defaults to space") { |o| @options[:append_delimiter] = o }
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
          set_property - Set the value of a property on one or more applicable Anthill Pro resources--project, agent, workflow, or environment

        SYNOPSIS
          set_property [options]

        OPTIONS
          Option arguments tend to be regexes and/or comma-separated.

          [ --remove ] - By default, set_property will ADD the requested property.

					[ --append ] - By default, set_property will replace the old value with the new value.  --append adds to the end, separating with <append_delimiter> (space by default).

					[ --append_delimiter ] - By default, delimiter for --append is a space.  Set an alternate delimiter, or "none".

          [ --no_exec ] - Do everything as normal, but stop short of setting any properties.

          --resource_type type[,type,...] - Where type is one of the following:
              agent
							workflow
              project
              env - environment (not common)

          --key aKey - The name of the property to add or update.

          --value aValue - The value to assign to the property

          --resource_name name[,name,...] - The option arg is either "all" or a case-insensitive regular
              expression.  The operation is applied to all resources whose names match the regex.  If "all" is specified,
              the property is set/updated for all resources of the indicated type(s).  I considered making "all" the
              default if --resource_name was not specified, but that would make it very easy to accidentally clobber a
              large number of properties.

        EXAMPLES

          Test-drive by setting property "myTestProperty" to "HiHowAreYa" for a list of agents, but don't actually do it.

              set_property --no_exec --resource_type agent --resource_name machine1,machine2,machine3 --key myTestProperty --value HiHowAreYa


          Remove property "myTestProperty" from all agents.

              set_property --resource_type agent --resource_name all --key myTestProperty --remove

        CAVEATS
          Sometimes the operation fails with an "Error restoring object from database" exception, especially
          for "agent" resources, if a large number of instances are returned.  As a workaround, try selecting
          a smaller number of instances by restricting the resource_name regex.

        BANNER

      end

    end
  end
end
