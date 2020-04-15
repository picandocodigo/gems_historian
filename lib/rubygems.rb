require 'open-uri'
require 'json'
require 'sequel'

module Rubygems
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/gems')

  # GET - /api/v1/versions/[GEM NAME].(json|yaml)
  #
  def self.downloads(name)
    gem_downloads = JSON.parse(
      URI.parse("https://rubygems.org/api/v1/versions/#{name}.json").read
    ).map do |gem|
      {
        name: name,
        version: gem['number'],
        downloads: gem['downloads_count'],
        prerelease: gem['prerelease'],
        created_at: gem['created_at']
      }
    end
    save_register(gem_downloads)
  end

  # Save results
  def self.save_register(gem_downloads)
    table = DB[:downloads]
    table.multi_insert(gem_downloads)
  end

  def self.create_table
    return if DB.table_exists?(:downloads)

    DB.create_table :downloads do
      primary_key :id
      String :name
      String :version
      Bignum :downloads
      FalseClass :prerelease
      DateTime :created_at
    end
  end
end
