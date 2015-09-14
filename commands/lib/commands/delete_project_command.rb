module AhpTools
  module Commands
    class DeleteProjectCommand < Base
      import "com.urbancode.anthill3.domain.agent"
      import "com.urbancode.anthill3.domain.jobtrace.vanilla.VanillaJobTraceFactory"
      import "com.urbancode.anthill3.domain.buildlife.BuildLifeFactory"
      import "com.urbancode.anthill3.domain.persistent.PersistenceException"
      import "com.urbancode.anthill3.domain.project.ProjectFactory"

      def initialize options
        super
        @project_id = options[:project]
        @project = nil
      end # def initialize

      def run
        chosen_buildlife = nil
        authenticated_uow do

          begin
	    handle = ProjectFactory::instance.restore_named_handle @project_id.to_i
	    if handle.nil?
	      puts "No such project with id '" + @project_id + "'"
	      exit 1
	    end

	    @project_name = handle.name
	    # Choose the project name that matches the ID (some projects have same name)
	    ProjectFactory::instance.restore_all_for_name( @project_name ).each do |p|
	       @project = p if p.id == @project_id.to_i
	    end

	    # Make sure project is deactivated
	    if @project.active?
	      puts "Project #{@project_id} '#{@project_name}' must be deactivated first."
	      return
	    end

          rescue PersistenceException => e
            puts "Exception searching for project '" + @project_name + "': " + e
            exit 1
          end # begin

          puts "Processing project '" + @project_name + "', id = " + @project.id.to_s

	  jobtraces = VanillaJobTraceFactory::instance.restore_all_misc_for_project @project
	  unless jobtraces.empty?
	    puts "Deleting #{jobtraces.count} misc jobs for project #{@project.id.to_s}..."
	    jobtraces.each do |jt|
	      jt.delete()
	    end
	  end
          begin
            buildlives = BuildLifeFactory::instance.restore_all_for_project @project
	    unless buildlives.empty?
	       puts "Deleting #{buildlives.count} buildlives for project #{@project.id.to_s}..."
               buildlives.each do |buildlife|
                 buildlife.delete()
	       end
            end
          rescue PersistenceException => e
            puts "Exception searching for list of build lives: " + e
            exit 3
          end # begin
        end # authenticated_uow
	puts "Project #{@project_id} '#{@project_name}' should be deletable now.  If not, check for deactivated workflows and *activate* them first (yes, it's crazy but it's true)."
      end  # def run

    end # class DeleteProjectCommand < Base
  end # module Commands
end # module AhpTools
