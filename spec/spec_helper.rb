require 'logger'

plugin_spec_dir = File.dirname(__FILE__)
plugin_lib_dir = File.join(plugin_spec_dir, '..', 'lib')

require File.join(plugin_lib_dir, 'no_peeping_toms')

# Setup ActiveRecord
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")
databases = YAML::load(IO.read(plugin_spec_dir + "/db/database.yml"))
ActiveRecord::Base.establish_connection(databases[ENV["DB"] || "sqlite3"])
load(File.join(plugin_spec_dir, "db", "schema.rb"))
