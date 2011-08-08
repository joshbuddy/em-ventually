module EventMachine
  module Ventually
    module Emify
      def _em
        result = nil
        if EM.reactor_running?
          result = yield
        else
          EM.run do
            begin
              result = yield
            ensure
              EM.stop if (!instance_variable_defined?(:@_pool) || @_pool.nil? || @_pool.empty?) && EM.reactor_running?
            end
          end
        end
        result
      end
    end
  end
end