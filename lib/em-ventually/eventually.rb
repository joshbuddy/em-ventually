module EventMachine
  module Ventually
    class Eventually

      autoload :MiniTest, 'em-ventually/eventually/minitest'
      autoload :RSpec,    'em-ventually/eventually/rspec'
      autoload :TestUnit, 'em-ventually/eventually/testunit'

      attr_reader :expectation

      def initialize(pool, runner, caller, expectation, opts, block)
        @pool, @runner, @caller, @expectation, @opts, @block = pool, runner, caller, expectation, opts, block
        @count = 0
        @pool.push self
        @total_time = opts && opts[:total] || EventMachine::Ventually.total_default
        @every_time = opts && opts[:every] || EventMachine::Ventually.every_default
        run
      end

      def assert_equal(got)
        got == expectation
      end

      def formatted_message(msg)
        "#{msg} (#{@caller.filename}:#{@caller.line})"
      end

      def kill_timer
        @kill_timer ||= EM.add_timer(@total_time) { stop(formatted_message("Exceeded time, expected #{expectation.inspect}, last value was #{@last_val.inspect}")) }
      end

      def run
        if @pool.should_run?(self)
          kill_timer
          if @block.arity != 1
            process_equality(@last_val = @block.call)
          else
            @block[proc { |val|
              @last_val = val
              process_equality(val)
            }]
          end
        else
          EM.add_timer(@every_time) { run }
        end
      end

      def process_equality(val)
        if assert_equal(val)
          stop
        else
          @count += 1
          EM.add_timer(@every_time) { run }
        end
      end

      def stop(msg = nil)
        EM.cancel_timer @kill_timer
        @pool.complete(self)
        report(msg) if msg
        if @pool.empty? && EM.reactor_running?
          EM.stop
        end
      end

      def report(msg)
        STDERR << "Msg: #{msg}\n"
      end
    end
  end
end