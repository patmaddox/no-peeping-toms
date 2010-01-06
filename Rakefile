begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
  exit 1
end
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'
require "load_multi_rails_rake_tasks" 

Jeweler::Tasks.new do |s|
  s.name = "no_peeping_toms"
  s.summary = "Disables observers during testing, allowing you to write model tests that are completely decoupled from the observer."
  s.description = s.summary
  s.email = "pat.maddox@gmail.com"
  s.homepage = "http://github.com/patmaddox/no-peeping-toms"
  s.authors = ["Pat Maddox", "Brandon Keepers"]
  s.add_dependency "activerecord", ['>= 1.1']
  s.files -= ['.gitignore', 'init.rb']
  s.test_files = Dir['spec/**/*']
  s.test_files -= ['spec/debug.log']
end

Jeweler::GemcutterTasks.new
