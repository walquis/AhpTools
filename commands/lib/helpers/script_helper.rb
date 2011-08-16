module AhpTools

  module Helpers

    module ScriptHelper

      import "com.urbancode.anthill3.domain.script.job"
      import "com.urbancode.anthill3.domain.workdir"

      def find_work_dir_script(name)
        WorkDirScriptFactory::instance.restore_for_name(name)
      end

      def find_job_pre_condition_script(name)
        JobPreConditionScriptFactory::instance.restore_for_name(name)
      end

    end

  end

end

