module AhpTools

  module Helpers

    module BuildProfileHelper

      import "com.urbancode.anthill3.domain.profile"

      def build_profile(project, originating_workflow, source_config, &block)
        result = BuildProfile.new(project, "")
        result.set_workflow(originating_workflow)
        result.set_source_config(source_config)

        yield result

        result.store
      end

      def build_artifacts(artifact_set, base_dir)
        deliver_pattern = ArtifactDeliverPatterns.new
        deliver_pattern.artifact_set = artifact_set
        deliver_pattern.base_directory = base_dir
        deliver_pattern.artifact_patterns = "*.zip\n*.tar.gz"
        deliver_pattern
      end

      def build_stamp_value(value)
        stamp_value = NewStampGenerator.new
        stamp_value.value = value
        stamp_value
      end

    end

  end

end





