module EventMachine
  module Ventually
    class Eventually
      class RSpec < Eventually
        def self.inject
          unless ::RSpec::Core::ExampleGroup.public_method_defined?(:_em)
            ::RSpec::Core::ExampleGroup.class_eval <<-EOT, __FILE__, __LINE__ + 1
            include EM::Ventually::Emify
            alias_method :original_instance_eval, :instance_eval
            def instance_eval(&block)
              _em { original_instance_eval(&block) }
            end
            EOT
          end
        end

        def report(msg)
          ::RSpec::Expectations.fail_with(msg)
        end

        def assert_test(result)
          e = expectation
          if super
            msg = formatted_message("#{result.inspect} passed")
            @runner.instance_eval do
              1.should == 1
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