module AhpTools

  module Helpers

    module LifeCycleHelper

      import "com.urbancode.anthill3.domain.lifecycle"

      def find_life_cycle_model(name)
        life_cycle_model = LifeCycleModelFactory.instance.restore_for_name(name)
        if life_cycle_model.nil?
          raise "could not find the lifecyle named '#{name}', please ensure it exists before running this command"
        end
        life_cycle_model
      end

    end

  end

end



