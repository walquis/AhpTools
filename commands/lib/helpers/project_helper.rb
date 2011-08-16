module AhpTools

  module Helpers

    module ProjectHelper

      import "com.urbancode.anthill3.domain.project"
      import "com.urbancode.anthill3.domain.folder"
      import "com.urbancode.anthill3.domain.agentfilter.any"
      import "com.urbancode.anthill3.domain.project.prop"

      def build_project(name, life_cycle_model, environment_group)
        project = ProjectFactory::instance.restore_for_name(name)

        if project.nil?
          project = Project.new(name)
          project.folder = FolderFactory.instance.restore_root
          project.life_cycle_model = life_cycle_model
          project.environment_group = environment_group

          quiet_period = QuietPeriodConfigChangeLog.new
          quiet_period.agent_filter = AgentFilterImplAny.new
          project.quiet_period_config = quiet_period

          project_name_property = ProjectProperty.new
          project_name_property.name = "project_name"
          project_name_property.value = name
          project.add_property(project_name_property)

          project.store
        end

        project
      end

    end

  end

end

