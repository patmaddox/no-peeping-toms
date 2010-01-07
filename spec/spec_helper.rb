require 'rubygems'
require 'multi_rails'
require 'multi_rails_init'
require File.expand_path(File.dirname(__FILE__) + '/host_app/spec/spec_helper')
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'no_peeping_toms'

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

databases = YAML::load(IO.read(plugin_spec_dir + "/db/database.yml"))
ActiveRecord::Base.establish_connection(databases[ENV["DB"] || "sqlite3"])
load(File.join(plugin_spec_dir, "db", "schema.rb"))
