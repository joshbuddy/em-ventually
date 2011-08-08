module EventMachine
  module Ventually
    class Eventually
      class RSpec < Eventually
        def self.inject
          ::RSpec::Core::ExampleGroup.class_eval <<-EOT, __FILE__, __LINE__ + 1
          alias_method :original_instance_eval, :instance_eval
          def instance_eval(&block)
            _em do
              original_instance_eval(&block)
            end
          end

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
          EOT
        end

        def report(msg)
          ::RSpec::Expectations.fail_with(msg)
        end

        def assert_equal(result)
          e = expectation
          if result == expectation
            @runner.instance_eval do
              result.should == e
            end
            true
          else
            false
          end
        end
      end
    end
  end
end