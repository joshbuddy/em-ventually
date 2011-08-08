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
        @test_blk = expectation.nil? ? proc{|r| r } : proc{|r| expectation == r}
        EM.add_timer(0.05) { run }
      end

      def test(&blk)
        @test_blk = blk
      end

      def assert_test(got)
        @test_blk[got]
      end

      def formatted_message(msg)
        "#{msg} (#{@caller.filename}:#{@caller.line})"
      end

      def kill_timer
        @kill_timer ||= EM.add_timer(@total_time) { stop(formatted_message("Exceeded time#{", expected #{expectation.inspect}" unless expectation.nil?}, last value was #{@last_val.inspect}")) }
      end

      def run
        if @pool.should_run?(self)
          kill_timer
          if @block.arity != 1
            process_test(@last_val = @block.call)
          else
            @block[proc { |val|
              @last_val = val
              process_test(val)
            }]
          end
        else
          EM.add_timer(@every_time) { run }
        end
      end

      def process_test(val)
        if assert_test(val)
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