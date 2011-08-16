module AhpTools
  module Commands
    class DeployCommand < Base
      import "com.urbancode.anthill3.domain.agent"
      import "com.urbancode.anthill3.domain.buildrequest.BuildRequest"
      import "com.urbancode.anthill3.domain.buildrequest.BuildRequestFactory"
      import "com.urbancode.anthill3.domain.buildrequest.BuildRequestStatusEnum"
      import "com.urbancode.anthill3.domain.buildrequest.RequestSourceEnum"
      import "com.urbancode.anthill3.domain.buildlife.BuildLifeFactory"
      import "com.urbancode.anthill3.domain.persistent.PersistenceException"
      import "com.urbancode.anthill3.domain.project.ProjectFactory"
      import "com.urbancode.anthill3.domain.property.PropertyValue"
      import "com.urbancode.anthill3.domain.security.UserFactory"
      import "com.urbancode.anthill3.domain.servergroup.ServerGroupFactory"
      import "com.urbancode.anthill3.domain.workflow.WorkflowCaseFactory"
      import "com.urbancode.anthill3.runtime.scripting.helpers.PropertyLookup"
      import "com.urbancode.anthill3.runtime.scripting.helpers.WorkflowLookup"
      import "com.urbancode.anthill3.runtime.scripting.helpers.BuildRequestLookup"
      import "com.urbancode.anthill3.services.agent.AgentManager"
      import "com.urbancode.anthill3.services.build.BuildService"
      import "com.urbancode.devilfish.client.ServiceEndpoint"

      def initialize options
        super
        @label              = options[:buildlabel]
        @workflow_to_run    = options[:workflow]
        @deploy_environment = options[:environment]
        @username           = options[:username]
        @build_project      = options[:project]
        @agents             = options[:agents]
        @timeout            = options[:timeout].to_i
        @status_only        = options[:status_only]
        @debug              = options[:debug]

        @project = nil
        @workflow = nil
      end # def initialize

      def run
        chosen_buildlife = nil
        authenticated_uow do

          begin
            @project = ProjectFactory::instance.restore_for_name( @build_project )
          rescue PersistenceException => e
            puts "Exception searching for project '" + @build_project + "': " + e
            exit 1
          end # begin

          if @project.nil?
            puts "No such project: '" + @build_project + "'"
            exit 1
          end # if @project.nil?

          begin
            BuildLifeFactory::instance.restore_all_for_project( @project ).each do |buildlife|
              if @label.eql?( "latest" )
                @label = buildlife.get_latest_stamp_value
                if @debug
                  puts "Default label resolves to '" + @label + "'"
                end # if @debug
              end # if @label.eql?( "latest" )
              buildlife.get_stamp_array.each do |stamp|
                if stamp.get_stamp_value.eql?( @label )
                  chosen_buildlife = buildlife
                  break
                end # stamp.get_stamp_value.eql?( @label )
              end # buildlife.get_stamp_array.each do |stamp|
            end # BuildLifeFactory::instace.restore_all_for_project().each do |buildlife|
          rescue PersistenceException => e
            puts "Exception searching for list of build lives: " + e
            exit 3
          end # begin

          if chosen_buildlife.nil?
            puts "Couldn't find buildlife with a stamp that matches label '" + @label + "'."
            exit 2
          end # chosen_buildlife.nil?

          begin
            @workflow = WorkflowLookup.get_for_project_and_name(@project, @workflow_to_run )
          rescue PersistenceException => e
              puts "Exception searching for workflow named '" + @workflow_to_run + \
                "' in project '" + @project.name + "': " + e
              exit 4
          end # begin

          if @workflow.nil?
              puts "No workflow named '" + @workflow_to_run + "' in project '" + @project.name + "'."
              exit 4
          end # if @workflow.nil?

          if @status_only
            @deploy_environment = "(not needed)"  # If only retrieving status
          else
            begin
              environment = ServerGroupFactory::instance.restore_for_name( @deploy_environment )
              if environment.nil?
                puts "Couldn't find deploy_environment named '" + @deploy_environment.to_s + "'"
                exit 5
              end # if environment.nil?
            rescue PersistenceException => e
                puts "Couldn't get list of deploy_environments corresponding to '" + @deploy_environment.to_s + "'"
                exit 6
            end # begin
          end # if @status_only

          begin
            user = UserFactory::instance.restore_for_name( @username )
          rescue PersistenceException => e
            puts "Unable to authenticate as user #{@username}"
            exit 7
          end # begin

          begin
            new_buildrequest = BuildRequest.new( chosen_buildlife,
                                                 @workflow,
                                                 environment,
                                                 user,
                                                 RequestSourceEnum::MANUAL,
                                                 user
                                               )
          rescue PersistenceException => e
            puts "Unable to create new build request"
            exit 8
          end # begin

          begin
            if ( @agents.nil? || @agents.eql?( "" ) )
              # If the "dynamic_agents" property is defined in the workflow-to-run, then make sure
              # "dynamic_agents" is set in the new buildrequest, whether from the cmd line or through
              # the code below that populates it with all the agents in the deploy_environment...
              dynamic_agents_value = @workflow.get_property_value( "dynamic_agents" )
              if ! dynamic_agents_value.nil?
                agent_manager = AgentManager::instance
                agent_manager.on_line_endpoint_array( environment ).each do |endpoint|
                  begin
                    @agents = ( @agents || "" ) + "," + agent_manager.get_agent_status( endpoint ).agent.name
                  rescue PersistenceException => e
                    puts "Couldn't retrieve an agent's status from environment '" + environment + "'"
                    exit 9
                  end # begin
                end # agent_manager.on_line_endpoint_array( environment ).each do |endpoint|
              end # if ! dynamic_agents_value.nil?
            end
          rescue PersistenceException => e
            puts "Unable to access workflow's 'dynamic_agents' preoperty"
            exit 10
          end # begin

          begin
            new_buildrequest.set_property_value( "dynamic_agents", PropertyValue.new( @agents, false ) )
          rescue PersistenceException => e
            puts "Unable to set agents to '#{@agents}'"
            exit 11
          end # begin

          if not @status_only
            begin
              BuildService::instance.run_workflow( new_buildrequest )
            rescue PersistenceException => e
              puts "Unable to run workflow with new build request"
              exit 12
            end # begin

            puts "INFO: Kicked off " + info_message
          else
            puts "INFO: Retrieving status for " + info_message
          end # if not @status_only
        end # begin

        completed = nil

        total_duration = 0
        sleep_duration = 1  # second

        while completed.nil?
          authenticated_uow do
            begin
              this_buildrequest = BuildRequestFactory::instance.restore_for_build_life( chosen_buildlife )
              this_workflow = WorkflowCaseFactory::instance.restore_for_build_request( this_buildrequest )
            rescue PersistenceException => e
              puts "Error restoring workflowcase - build_request failed(?): " + e.message
              puts e.cause
            end # begin

            begin
              if this_workflow.status.is_done?
                completed = 1
                puts
                puts "Workflow Status: " + this_workflow.status.to_s.sub!( /^.*\[(\w+)\]$/, '\1' )
                exit 0
              end # if this_workflow.status.is_done?
            rescue Exception => e
              if e.class.equal?( NoMethodError )
                puts "Unknown error polling status: Bailing (though deploy might still be running)"
                exit 14
              end # if e.class.equal?( NoMethodError )
            end # begin
            print "."
            sleep sleep_duration
            total_duration += sleep_duration
            if total_duration >= @timeout
              puts "Timeout exceeded, last status is: " + this_workflow.status.to_s
              exit 8
            end # if total_duration >= @timeout
          end # authenticated_uow do
        end # while completed.nil?
        puts
      end  # def run

      def info_message
        "workflow '#{@workflow_to_run}' (id = #{@workflow.get_id.to_s}) in buildlife having stamp '#{@label}' for project '#{@project.name}' (id = #{@project.get_id.to_s}), targeting deploy_environment '#{@deploy_environment}' with a polling timeout of #{@timeout.to_s} seconds, as user '#{@username}'."
      end # def info_message
    end # class DeployCommand < Base
  end # module Commands
end # module AhpTools
