# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "em-ventually/version"

Gem::Specification.new do |s|
  s.name        = "em-ventually"
  s.version     = EventMachine::Ventually::VERSION
  s.authors     = ["Josh Hull"]
  s.email       = ["joshbuddy@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "em-ventually"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # dependencies
  s.add_runtime_dependency 'eventmachine'
  s.add_runtime_dependency 'callsite'
  s.add_development_dependency 'code_stats'
  s.add_development_dependency 'rake',     '~> 0.8.7'
  s.add_development_dependency 'phocus'
  s.add_development_dependency 'bundler',  '~> 1.0.0'
end
