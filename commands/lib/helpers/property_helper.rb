module AhpTools
	module Helpers
		module PropertyHelper

			class PropertySetter
			  include ResourceHelper

				attr_reader :no_exec, :remove, :resource_type_name, :resource_name_filter, :key, :value, :append, :append_delimiter

				def initialize(key,value,resource_type_name,resource_name_filter,remove,no_exec,append,append_delimiter)
					@no_exec = no_exec
					@remove = remove
					@resource_type_name = resource_type_name
					@resource_name_filter = resource_name_filter
					@key = key
					@value = value
					@append = append
					@append_delimiter = (append_delimiter =~ /none/) ? "" : append_delimiter
				end


				def set_property()
					set_property_on_resources( retrieve(resource_type_name, resource_name_filter) )
				end


				def set_property_on_resources(resources)
					did_something = false

					resources.each do |r|
						if r.respond_to?("ahptools_set_property")
							r.ahptools_set_property(key,value,remove,no_exec,append,append_delimiter)
							did_something = true
						else
							puts "Resource type #{r.class.to_s} does not respond to ahptools_set_property() method"
						end
					end

					did_something
				end
      end   # class PropertySetter


			# Crack open the Java class and add our own methods for property setting...
			class Java::ComUrbancodeAnthill3DomainServergroup::ServerGroup
				import "com.urbancode.anthill3.domain.servergroup"
				import "com.urbancode.anthill3.domain.property"

				def ahptools_set_property(key,value,remove,no_exec,append,append_delimiter)
					prop = get_property_value(key)
					if (!remove)
						if prop.nil?
							print "Environment = #: Adding property #{key} = #{value}...\n"
							no_exec or set_property_value(key, PropertyValue.new(value,false))
						else
							old_value = prop.get_value()
							new_value = append ? old_value + append_delimiter + value : value
							print "Environment = #{name}: Updating property #{key}.  Old value = '#{old_value}', new value = '#{new_value}'\n"
							no_exec or set_property_value(key, PropertyValue.new(new_value,false))
						end
					else # Removing...
						if prop.nil?
							print "Environment = #{name}: Property #{key} does not exist\n"
						else
							old_value = prop.get_value()
							print "Environment = #{name}: Removing property #{key} with value '#{old_value}'\n"
							no_exec or remove_property_value(key)
						end
					end # If !remove
				end
			end


			class Java::ComUrbancodeAnthill3DomainAgent::Agent
				import "com.urbancode.anthill3.domain.agent.Agent"
				import "com.urbancode.anthill3.domain.property"

				def ahptools_set_property(key,value,remove,no_exec,append,append_delimiter)
					old_value = get_property_value(key)
					if (!remove)
						if old_value.nil?
							print "Agent = #{name}: Adding #{key} = #{value}...\n"
						else
							new_value = append ? "#{old_value}#{append_delimiter}#{value}" : value
							print "Agent = #{name}: Updating #{key}.  Old value = '#{old_value}', new value = '#{new_value}'\n"
						end
						no_exec or set_property_value(key, PropertyValue.new(new_value,false))
					else # Removing...
						if old_value.nil?
							print "Agent = #{name}: Property #{key} does not exist\n"
						else
							print "Agent = #{name}: Removing property #{key} with value '#{old_value}'\n"
							no_exec or remove_property_value(key)
						end
					end
				end
			end


			class Java::ComUrbancodeAnthill3DomainWorkflow::Workflow
				import "com.urbancode.anthill3.domain.workflow"
				import "com.urbancode.anthill3.domain.property"

				def ahptools_set_property(key,value,remove,no_exec,append,append_delimiter)
					wfProp = get_property(key)
					if (!remove)
						if wfProp.nil?
							print "Workflow = #{name}: Adding property #{key} = #{value}...\n"
							wfProp = WorkflowProperty.new(key,WorkflowPropertyTypeEnum::TEXT)
							wfProp.set_property_value(PropertyValue.new(value,false))
							no_exec or add_property(wfProp)
						else
							old_value = wfProp.get_property_value()
							new_value = append ? old_value + append_delimiter + value : value
							print "Workflow = #{name}: Updating property #{key}.  Old value = '#{old_value}', new value = '#{new_value}'\n"
							no_exec or wfProp.set_property_value(PropertyValue.new(new_value,false))
						end
					else # Removing...
						if wfProp.nil?
							print "Workflow = #{name}: Property #{key} does not exist\n"
						else
							old_value = wfProp.get_property_value()
							print "Workflow = #{name}: Removing property #{key} with value '#{old_value}'\n"
							no_exec or remove_property(wfProp)
						end
					end # If !remove
				end
			end


			class Java::ComUrbancodeAnthill3DomainProject::Project
				import "com.urbancode.anthill3.domain.project"
				import "com.urbancode.anthill3.domain.project.prop"

				def ahptools_set_property(key,value,remove,no_exec,append,append_delimiter)
					prop = get_property(key)
					if (!remove)
						if prop.nil?
							print "Project = #{name}: Adding property #{key} = #{value}...\n"
							prop = ProjectProperty.new(key)
							prop.set_value(value)
							no_exec or add_property(prop)
						else
							old_value = prop.get_value()
							new_value = append ? old_value + append_delimiter + value : value
							print "Project = #{name}: Updating property #{key}.  Old value = '#{old_value}', new value = '#{new_value}'\n"
							no_exec or prop.set_value(new_value)
						end
					else # Removing...
						if prop.nil?
							print "Project = #{name}: Property #{key} does not exist\n"
						else
							old_value = prop.get_value()
							print "Project = #{name}: Removing property #{key} with value '#{old_value}'\n"
							no_exec or remove_property(prop)
						end
					end # If !remove
				end
			end

		end
	end
end
