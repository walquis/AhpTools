module AhpTools
	module Helpers

		module SecurityHelper

			class SecuritySetter
			  include ResourceHelper

				import "com.urbancode.anthill3.domain.security"

				attr_reader :no_exec, :remove, :resource_type_name, :resource_name_filter, :action_name, :role_name, :op, :role

				def initialize(role_name,resource_type_name,resource_name_filter,action_name,remove,no_exec)
					@no_exec = no_exec
					@remove = remove
					@resource_type_name = resource_type_name
					@resource_name_filter = resource_name_filter
					@action_name = action_name
					@role_name = role_name

					@op = remove ? "DELETE" : "ADD"

				end


				def set_security()

					@role = RoleFactory::instance.restore_for_name(role_name)

					if ! set_permission_on_resources( retrieve(resource_type_name, resource_name_filter) )
						print "No '#{resource_type_name}' resources that need '#{action_name}' perms #{op}'d for role '#{role_name}'\n"
					end

				end


				def set_permission_on_resources(resources)
					did_something = false

					resources.each do |r|
					  n = r.name
					  if r.respond_to?("project")
					    n = r.project.name + " -- " + n
				    end

#					  print "Resource name = #{n}, ID = ", r.object_id, ", endpointID = ", r.endpoint_id, ", is_deleted = ", r.is_deleted, "\n"

						resource = ResourceFactory::instance.restore_for_persistent(r)
						permlist = PermissionFactory::instance.restoreAllForResource(resource)
						found = false
						permlist.each do |perm|
							if (perm.action == action_name and perm.role.name == role_name)
#    						print "Resource name = #{n}", ", perm.action = ", perm.action, "\n"
								if (remove)
									print "'#{resource_type_name}': #{op}-ing permission '#{action_name}' for role '#{role_name}' from '#{n}' ...\n"
									if ! no_exec
										perm.delete()
									end
									did_something = true
								else
									found = true
								end

								break
							end
						end
						if ( !remove and !found )
							print "Resource = #{n}: #{op}'ing #{action_name} permission for role #{role_name}...\n"
							if ! no_exec
								Permission.new(resource, action_name, role).store()
							end
							did_something = true
						end
					end
					did_something
				end
      end   # class

		end
	end
end
