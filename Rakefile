require 'dotenv/load'
require_relative './lib/gems_historian.rb'

desc "Update gem downloads"
task :update_gems do
  ENV['GEMS'].split(/\s{1}/).each do |gem|
    puts "Downloading data for #{gem}"
    GemsHistorian.new.downloads(gem)
  end
end

desc "Setup the database"
task :setup do
  GemsHistorian.new.create_table
end
