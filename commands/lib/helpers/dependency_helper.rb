module AhpTools

  module Helpers

    module DependencyHelper

      import "com.urbancode.codestation2.domain.project"
      import "com.urbancode.anthill3.domain.profile"

      def build_dependency(dependent_project_name, dependency_project_name, &block)
        projects = CodestationProjectFactory::instance.restoreAllAnthill

        dependent_project = projects.find { |proj| proj.name =~ /#{dependent_project_name}/ }
        dependency_project = projects.find { |proj| proj.name =~ /#{dependency_project_name}/  }

        dependency = Dependency.new(dependent_project, dependency_project)
        yield dependency
        dependency.store

        dependency
      end

    end

  end

end


