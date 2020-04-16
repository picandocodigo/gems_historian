require 'yaml'
require_relative './lib/gems_historian.rb'

desc "Update gem downloads"
task :update_gems do
  YAML.load(File.read('config.yml'))['gems'].each do |gem|
    GemsHistorian.new.downloads(gem)
  end
end

desc "Setup the database"
task :setup do
  GemsHistorian.create_table
end
