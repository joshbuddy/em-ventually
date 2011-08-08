require 'em-ventually'

RSpec::Core::ExampleGroup.class_eval do
  include EM::Ventually
end