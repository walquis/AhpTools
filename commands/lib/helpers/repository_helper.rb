module AhpTools

  module Helpers

    module RepositoryHelper

      import "com.urbancode.anthill3.domain.repository"
      import "com.urbancode.anthill3.domain.repository.file"

      def build_file_repository(name)
        repo = RepositoryFactory.instance.restore_for_name(name)
        if repo.nil?
          info "creating #{name}"
          repo = FileRepository.new(true)
          repo.name = name
          repo.store
        end
        repo
      end
    end

  end

end


