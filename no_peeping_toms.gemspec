# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "no_peeping_toms/version"

Gem::Specification.new do |s|
  s.name        = "no_peeping_toms"
  s.version     = NoPeepingToms::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Pat Maddox"]
  s.email       = ["pat.maddox@gmail.com"]
  s.homepage    = "https://github.com/patmaddox/no-peeping-toms"
  s.summary     = %q{Disables observers during testing, allowing you to write model tests that are completely decoupled from the observer.}
  s.description = %q{Disables observers during testing, allowing you to write model tests that are completely decoupled from the observer.}
  s.rubyforge_project = "no_peeping_toms"

  s.files         = Dir["*.rdoc", "{lib,spec}/**/*"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activerecord', '>=3.0.0'
  s.add_runtime_dependency 'activesupport', '>=3.0.0'

  s.add_development_dependency 'rspec', '~>2.5'
  s.add_development_dependency 'sqlite3'
end
