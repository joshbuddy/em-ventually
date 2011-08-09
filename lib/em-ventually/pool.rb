module EventMachine
  module Ventually
    class Pool
      def initialize
        @store = []
      end

      def should_run?(eventually)
        case @store.first
        when Array
          @store.first.include?(eventually)
        else
          @store.first == eventually
        end
      end

      def in_parallel
        @store.push []
        yield
      end

      def push(e)
        if @store.last.is_a?(Array)
          @store.last.last.run unless @store.last.last.nil?
          @store.last.push(e)
        else
          @store.last.run unless @store.last.nil?
          @store.push(e)
        end
      end

      def complete(e)
        if @store.first.is_a?(Array)
          @store.first.delete(e)
          @store.shift if @store.last.empty?
        else
          @store.delete(e)
        end
      end

      def empty?
        @store.empty?
      end
    end
  end
end