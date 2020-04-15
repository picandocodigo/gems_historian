require 'yaml'
require_relative './lib/rubygems.rb'

desc "Update gem downloads"
task :update_gems do
  YAML.load(File.read('config.yml'))['gems'].each do |gem|
    Rubygems.downloads(gem)
  end
end

desc "Setup the database"
task :setup do
  Rubygems.create_table
end
