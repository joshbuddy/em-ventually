require 'em-ventually'

Test::Unit::TestCase.class_eval do
  include EM::Ventually
end
