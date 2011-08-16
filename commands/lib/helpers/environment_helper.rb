module AhpTools

  module Helpers

    module EnvironmentHelper

      import "com.urbancode.anthill3.domain.servergroup"
      import "com.urbancode.anthill3.domain.environmentgroup"

      def build_environments(environments)
        server_groups = []
        environments.each do |name|
          environment = ServerGroupFactory::instance.restore_for_name(name)
          if environment.nil?
            environment = ServerGroup.new
            environment.name = name
            environment.store
            server_groups << environment
          end
        end
        return server_groups
      end

      def build_environment_group(name, environments)
        environment_group = EnvironmentGroupFactory::instance.restore_for_name(name)

        if environment_group.nil?
          environment_group = EnvironmentGroup.new(true)
          environment_group.name = name
        end

        environments.each do |e|
          environment_group.add_server_group(e)
        end

        environment_group.add_server_group(ServerGroupFactory::instance.restore_for_name("Deploy Farm"))
        environment_group.store
        return environment_group
      end

      def find_deploy_farm_environment
        ServerGroupFactory::instance.restore_for_name("Deploy Farm")
      end

      def find_environment_groups
        EnvironmentGroupFactory::instance.restore_all
      end

    end
  end

end
