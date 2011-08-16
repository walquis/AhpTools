module AhpTools

  module Helpers

    module JobHelper

      import "com.urbancode.anthill3.domain.jobconfig"
      import "com.urbancode.anthill3.domain.workflow"

      def find_library_job(name)
        JobConfigFactory::instance.restore_library_for_name(name)
      end

      def build_iterate_all_plan
        iterate_all = JobIterationPlan.new
        iterate_all.iterations = -1
        iterate_all.max_parallel_jobs = -1
        iterate_all.parallel_iteration = true
        iterate_all.running_on_unique_agents = true
        iterate_all
      end

    end

  end

end
