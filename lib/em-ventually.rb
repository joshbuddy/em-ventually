require 'set'
require 'eventmachine'
require 'callsite'
require 'em-ventually/eventually'
require 'em-ventually/emify'
require 'em-ventually/pool'
require 'em-ventually/version'

module EventMachine
  module Ventually
    def self.every_default=(value)
      @every_default = value
    end

    def self.every_default
      instance_variable_defined?(:@every_default) ? @every_default : 0.1
    end

    def self.total_default=(value)
      @total_default = value
    end

    def self.total_default
      instance_variable_defined?(:@total_default) ? @total_default : 1.0
    end

    def _pool
      @_pool ||= Pool.new
    end

    def eventually(expectation = nil, opts = nil, &block)
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
    alias_method :ly, :eventually

    def manually_stop_em!
      @_manually_stop_em = true
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
      elsif (o.respond_to?(:name) && o.name.to_s == 'RSpec::Core::ExampleGroup') || (o.respond_to?(:superclass) && o.superclass.to_s == 'RSpec::Core::ExampleGroup')
        Eventually::RSpec
      else
        raise("I know what testsuite i'm in!")
      end
      cls.inject
    end
  end
end
