module AhpTools

  module Helpers

    module WorkflowHelper

      import "com.urbancode.anthill3.domain.workflow"

      def build_workflow(name, project, &block)
        workflow = Workflow.new(project)
        workflow.name = name
        yield workflow
        workflow.store
        workflow
      end

      def build_property(name, type, user_may_override)
        property = WorkflowProperty.new(type)
        property.name = name
        property.user_may_override = user_may_override
        property
      end

    end

  end

end




