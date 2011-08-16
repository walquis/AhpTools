module AhpTools

  module Helpers

    module FileSourceConfigHelper

      import "com.urbancode.anthill3.domain.source.file"

      def build_file_source_config(project, repository, working_dir_script, &block)
        file_source_config = FileSourceConfig.new(@project, "dummy")
        file_source_config.repository = @repo
        file_source_config.work_dir_script = @working_directory_script
        yield file_source_config if block_given?
        file_source_config.store
        file_source_config
      end

    end

  end

end






