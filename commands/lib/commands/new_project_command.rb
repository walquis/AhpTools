module AhpTools

  module Commands

    class NewProjectCommand < Base

      import "com.urbancode.anthill3.domain.script.agentfilter"
      import "com.urbancode.anthill3.domain.workflow"
      import "com.urbancode.anthill3.domain.agentfilter.scripted"
      import "com.urbancode.anthill3.domain.agentfilter.any"

      include Helpers::EnvironmentHelper
      include Helpers::JobHelper
      include Helpers::ScriptHelper
      include Helpers::RepositoryHelper
      include Helpers::LifeCycleHelper
      include Helpers::ProjectHelper
      include Helpers::WorkflowHelper
      include Helpers::WorkflowDefinitionHelper
      include Helpers::BuildProfileHelper
      include Helpers::FileSourceConfigHelper
      include Helpers::DependencyHelper

      def run
        @environment_names = %w(QA Production Development).map { |env| @options[:project] + " " + env }
        @environment_group_name = @options[:project] + " Group"

        authenticated_uow do
          @working_directory_script = find_work_dir_script("Project + Build Num Work Dir")
          @parent_job_success_script = find_job_pre_condition_script("Parent Job Success")

          @library_extract_job = find_library_extract_job

          lib_job_name = "_lib - 0.0 Copy artifacts from build system (ddt)"
          @library_build_job = find_library_job(lib_job_name)
          if @library_build_job.nil?
            raise "Could not find the library job named '#{lib_job_name}', please ensure it exists"
          end

          lib_job_name = "_lib - 1.1 Deploy"
          @library_deploy_job = find_library_job(lib_job_name)
          if @library_deploy_job.nil?
            raise "Could not find the library job named '#{lib_job_name}', please ensure it exists"
          end

          lib_job_name = "_lib - 2.0 Activate"
          @library_activate_job = find_library_job(lib_job_name)
          if @library_activate_job.nil?
            raise "Could not find the library job named '#{lib_job_name}', please ensure it exists"
          end

          info "creating environments #{@environment_names.join(', ')}"
          @environments = build_environments(@environment_names)

          info "creating environment group #{@environment_group}"
          @environment_group = build_environment_group(@environment_group_name, @environments)

          info "creating file repository"
          @repo = build_file_repository(@options[:repository])

          info "finding lifecycle model"
          @life_cycle_model = find_life_cycle_model(@options[:life_cycle_model])

          info "finding bootstrap lifecycle model"
          @bootstrap_life_cycle_model = find_life_cycle_model("Bootstrap Lifecycle")

          info "creating project"
          @project = build_project(@options[:project], @life_cycle_model, @environment_group)

          info "creating build workflow"
          @build_workflow = create_build_workflow

          info "creating deploy workflow"
          @deploy_workflow = create_deploy_workflow

          info "creating file source config"
          @build_file_source_config = build_file_source_config(@project, @repo, @working_directory_script)

          info "creating build profile"
          @build_profile = create_build_profile
        end
      end

      private

      def find_library_extract_job
        extract_script_windows = "_lib - 1.0 Extract Deployment Scripts (windows)"
        extract_script_linux = "_lib - 1.0 Extract Deployment Scripts (unix)"
        extract_script = @options[:platform] == "win" ? extract_script_windows : extract_script_linux
        job = find_library_job(extract_script)
        if job.nil?
          raise "Could not find the library job named #{extract_script}, please ensure it exists"
        end
        return job
      end

      def create_build_workflow

        build_workflow("0.0 Copy artifacts from build system", @project) do |workflow|

          workflow.remove_all_server_groups
          workflow.add_server_group(find_deploy_farm_environment)
          workflow.add_property(build_property("buildLabel", WorkflowPropertyTypeEnum::TEXT, true))

          info "creating build workflow"
          workflow.workflow_definition = build_workflow_definition(workflow) do |workflow_definition|

            windows_agent_filter = AgentFilterScriptFactory::instance.restore_for_name("Windows OS")

            info "adding build job"
            add_job(workflow_definition,
                    :job => @library_build_job,
                    :agent_filter => AgentFilterImplScripted.new(windows_agent_filter),
                    :pre_condition_script => @parent_job_success_script,
                    :working_dir_script => @working_directory_script)

          end

        end


      end

      def create_deploy_workflow
        build_workflow("1.0 Deploy", @project) do |workflow|

          info "creating deploy workflow"

          workflow.workflow_definition = build_workflow_definition(workflow) do |workflow_definition|

            info "adding extract job"
            add_job(workflow_definition,
                    :job => @library_extract_job,
                    :agent_filter => AgentFilterImplAny.new,
                    :pre_condition_script => @parent_job_success_script,
                    :working_dir_script => @working_directory_script,
                    :iteration_plan => build_iterate_all_plan)

            info "adding deploy job"
            add_job(workflow_definition,
                    :parent => @library_extract_job,
                    :job => @library_deploy_job,
                    :agent_filter => AgentFilterImplAny.new,
                    :pre_condition_script => @parent_job_success_script,
                    :working_dir_script => @working_directory_script,
                    :iteration_plan => build_iterate_all_plan)

            info "adding activate job"
            add_job(workflow_definition,
                    :parent => @library_deploy_job,
                    :job => @library_activate_job,
                    :agent_filter => AgentFilterImplAny.new,
                    :pre_condition_script => @parent_job_success_script,
                    :working_dir_script => @working_directory_script,
                    :iteration_plan => build_iterate_all_plan)

          end

          end
      end

      def create_build_profile
        build_profile(@project, @build_workflow, @build_file_source_config) do |build_profile|

          artifact_set = @life_cycle_model.artifact_set_group.get_artifact_set(@options[:artifact_set])
          build_profile.add_artifact_config(build_artifacts(artifact_set, @options[:artifact_base_dir]))

          stamp_style = @life_cycle_model.stamp_style_group.get_stamp_style(@options[:stamp_style])
          build_profile.set_stamp_generator_for_stamp_style(stamp_style, build_stamp_value("${property:buildLabel}"))

        end
      end

    end


  end
end

