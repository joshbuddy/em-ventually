module EventMachine
  module Ventually
    class Eventually
      class TestUnit < Eventually
        def self.inject
          unless ::Test::Unit::TestCase.public_method_defined?(:_em)
            ::Test::Unit::TestCase.class_eval <<-EOT, __FILE__, __LINE__ + 1
            include EM::Ventually::Emify
            alias_method :__original__send__, :__send__
            old_warning_level = $VERBOSE
            $VERBOSE = nil
            def __send__(*args, &blk)
              if Callsite.parse(caller.first).method == 'run'
                _em { __original__send__(*args, &blk) }
              else
                __original__send__(*args, &blk)
              end
            end
            $VERBOSE = old_warning_level
            EOT
          end
        end

        def report(msg)
          @runner.assert false, msg
        end

        def assert_test(result)
          e = expectation
          if super
            msg = formatted_message("#{result.inspect} passed")
            @runner.instance_eval do
              assert true, msg
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