require 'set'
require 'eventmachine'
require 'callsite'
require 'em-ventually/eventually'
require 'em-ventually/emify'
require 'em-ventually/pool'
require 'em-ventually/version'

module EventMachine
  module Ventually
    def _pool
      @_pool ||= Pool.new
    end

    def eventually(expectation = true, opts = nil, &block)
      ancestors = self.class.ancestors.map{|s| s.to_s}
      cls = if ancestors.include?('MiniTest::Unit::TestCase')
        Eventually::MiniTest
      elsif ancestors.include?('Test::Unit::TestCase')
        Eventually::TestUnit
      elsif self.class.to_s[/^RSpec::Core/]
        Eventually::RSpec
      else
        nil
      end
      cls.new(_pool, self, Callsite.parse(caller.first), expectation, opts, block)
    end

    def parallel(&blk)
      _pool.in_parallel do
        instance_eval(&blk)
      end
    end

    def self.included(o)
      ancestors = o.ancestors.map{|s| s.to_s}
      cls = if ancestors.include?('MiniTest::Unit::TestCase')
        Eventually::MiniTest
      elsif ancestors.include?('Test::Unit::TestCase')
        Eventually::TestUnit
      elsif o.respond_to?(:superclass) && o.superclass.to_s == 'RSpec::Core::ExampleGroup'
        Eventually::RSpec
      else
        raise("I know what testsuite i'm in!")
      end
      cls.inject
    end
  end
end
