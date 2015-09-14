module AhpTools
  module Commands
    class CleanupMiscJobsCommand < Base
      import "com.urbancode.anthill3.domain.jobtrace.vanilla.VanillaJobTraceFactory"
      import "com.urbancode.anthill3.domain.project.ProjectFactory"

      def initialize options
        super
        @exec = options[:exec]
      end # def initialize

      def run
        chosen_buildlife = nil

        puts "exec = '" + @exec.to_s + "'"
        projects = []
        authenticated_uow do
          projects = ProjectFactory::instance.restore_all
        end
        projects.each do |p|
          miscjobtraces = []
          authenticated_uow do
            miscjobtraces = VanillaJobTraceFactory::instance.restore_all_misc_for_project p
          end
          if not @exec
            puts "(noexec) #{miscjobtraces.count} misc jobs for project '#{p.name}', id #{p.id.to_s}"
          else
            unless miscjobtraces.empty?
              puts "Deleting #{miscjobtraces.count} misc jobs for project  '#{p.name}', id #{p.id.to_s}..."
              authenticated_uow do
                miscjobtraces.each do |jt|
                  jt.delete()
                end
              end # authenticated_uow
            end
          end
        end # restore_all.each do...

      end  # def run
    end # class CleanupMiscJobsCommand < Base
  end # module Commands
end # module AhpTools
