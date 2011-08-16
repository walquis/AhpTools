module AhpTools
  module Commands

    class NewEnvironmentsCommand < Base

      include AhpTools::Helpers::EnvironmentHelper

      def run
        authenticated_uow do |uow|
          environments = build_environments(@options[:environments])
          build_environment_group(@options[:group], environments)
        end
      end

    end
  end

end
