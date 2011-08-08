module EventMachine
  module Ventually
    class Eventually
      class TestUnit < Eventually
        def self.inject
          ::Test::Unit::TestCase.class_eval <<-EOT, __FILE__, __LINE__ + 1
          alias_method :__original__send__, :__send__
          def __send__(*args, &blk)
            if Callsite.parse(caller.first).method == 'run'
              result = nil
              EM.run do 
                begin
                  result = __original__send__(*args, &blk)
                ensure
                  EM.stop if (!instance_variable_defined?(:@_pool) || @_pool.nil? || @_pool.empty?) && EM.reactor_running?
                end
                result
              end
            else
              __original__send__(*args, &blk)
            end
          end
          EOT
        end

        def report(msg)
          @runner.assert false, msg
        end

        def assert_equal(result)
          e = expectation
          if result == expectation
            @runner.instance_eval do
              assert_equal result, e
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