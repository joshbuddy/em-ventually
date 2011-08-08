require 'em-ventually'

MiniTest::Unit::TestCase.class_eval do
  include EM::Ventually
end
  