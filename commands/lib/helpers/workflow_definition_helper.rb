module AhpTools

  module Helpers

    module WorkflowDefinitionHelper

      import "com.urbancode.anthill3.domain.workflow"

      def build_workflow_definition(workflow, &block)
        workflow_definition = WorkflowDefinition.new(workflow)
        workflow_definition.name = workflow.name
        yield workflow_definition
        workflow_definition
      end

      def add_job(workflow_definition, options)
        if options.has_key?(:parent)
          workflow_definition.insertChildJob(options[:job], options[:parent])
        else
          workflow_definition.add_root_job(options[:job])
        end

        if options[:filter]
          workflow_definition.set_job_agent_filter(options[:job], options[:filter])
        end

        if options[:pre_condition_script]
          workflow_definition.set_job_pre_condition_script(options[:job], options[:pre_condition_script])
        end

        if options[:working_dir_script]
          workflow_definition.set_job_work_dir_script(options[:job], options[:working_dir_script])
        end

        if options[:iteration_plan]
          workflow_definition.set_job_iteration_plan(options[:job], options[:iteration_plan])
        end
      end

    end

  end

end





