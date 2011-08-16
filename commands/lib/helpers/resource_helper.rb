module AhpTools
	module Helpers
		module ResourceHelper

    	import "com.urbancode.anthill3.domain.persistent"
    	import "com.urbancode.anthill3.domain.agent.AgentFactory"
    	import "com.urbancode.anthill3.domain.servergroup"
    	import "com.urbancode.anthill3.domain.environmentgroup"
    	import "com.urbancode.anthill3.domain.project"
    	import "com.urbancode.anthill3.domain.folder"
    	import "com.urbancode.anthill3.domain.jobconfig"
    	import "com.urbancode.anthill3.domain.repository"
    	import "com.urbancode.anthill3.domain.lifecycle"
      import "com.urbancode.anthill3.domain.workflow.WorkflowFactory"
      import "com.urbancode.anthill3.domain.project.ProjectFactory"

    	def retrieve(resource_type_name, resource_name_filter)
    		p = nil
    		if (    resource_type_name.downcase == "agent".downcase )
    			p = AgentFactory::instance.restore_all

    		elsif ( resource_type_name.downcase == "envgroup".downcase )
    			p = EnvironmentGroupFactory::instance.restore_all

    		elsif ( resource_type_name.downcase == "env".downcase )
    			p = ServerGroupFactory::instance.restore_all

    		elsif ( resource_type_name.downcase == "project".downcase )
    			p = ProjectFactory::instance.restore_all

    		elsif ( resource_type_name.downcase == "folder".downcase )
    			p = FolderFactory::instance.restore_all

    		elsif ( resource_type_name.downcase == "libraryjob".downcase )
    			p = JobConfigFactory::instance.restore_all_library

    		elsif ( resource_type_name.downcase == "repository".downcase )
    			p = RepositoryFactory::instance.restore_all

    		elsif ( resource_type_name.downcase == "lifecyclemodel".downcase )
    			p = LifeCycleModelFactory::instance.restore_all

    		elsif ( resource_type_name.downcase == "workflow".downcase )
    			p = WorkflowFactory::instance.restore_all

    		elsif ( resource_type_name.downcase == "job".downcase )
    			p = JobConfigFactory::instance.restore_all

    		else
    			raise "'#{resource_type_name}': I do not know how to modify security for this resource type."
    		end

    		resources = []
    		if ( resource_name_filter =~ /^all$/i )
    		  resources = p
    		else
    			p.each do |r|
    				if ( r.name =~ /#{resource_name_filter}/i)
    					resources << r
    				end
    			end
    		end
    	  return resources
      end
    end
  end
end
