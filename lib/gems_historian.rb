require 'open-uri'
require 'json'
require 'sequel'
require 'elasticsearch'

class GemsHistorian
  def initialize
    data_storage
  end

  # GET - /api/v1/versions/[GEM NAME].(json|yaml)
  #
  def downloads(name)
    gem_downloads = JSON.parse(
      URI.parse("https://rubygems.org/api/v1/versions/#{name}.json").read
    ).map do |gem|
      {
        name: name,
        version: gem['number'],
        downloads: gem['downloads_count'],
        prerelease: gem['prerelease'],
        published_at: gem['created_at'],
        created_at: DateTime.now
      }
    end
    save_register(gem_downloads)
  end

  # Set up when using PostgreSQL, create the table
  def create_table
    if @db
      return if @db.table_exists?(:downloads)

      @db.create_table :downloads do
        primary_key :id
        String :name
        String :version
        Bignum :downloads
        FalseClass :prerelease
        DateTime :published_at
        DateTime :created_at
      end
    end
  end

  private

  def config
    @config ||= YAML.load(File.read('config.yml'))
  end

  # Check for Postgresql or Elasticsearch information to set up the right data
  # storage engine
  def data_storage
    if ENV['DATABASE_URL']
      @db ||= Sequel.connect(ENV['DATABASE_URL'])
    elsif (url = ENV['ELASTICSEARCH_URL'])
        @es ||= Elasticsearch::Client.new(url: url)
    elsif ENV['ELASTIC_CLOUD_ID']
        @es ||= Elasticsearch::Client.new(
          cloud_id: ENV['ELASTIC_CLOUD_ID'],
          user: ENV['ELASTIC_USERNAME'],
          password: ENV['ELASTIC_PASSWORD']
        )
    else
        raise "You need to set up either ELASTICSEARCH_URL or ELASTIC_CLOUD_ID and credentials in your environment to use Elasticsearch."
    end
  end

  # Save results
  def save_register(gem_downloads)
    if @db # Postgresql
      table = @db[:downloads]
      table.multi_insert(gem_downloads)
    elsif @es # Elasticsearch
      # Bulkify the data:
      payload = gem_downloads.map do |gem|
        {index: { _index: 'gems', data: gem } }
      end
      @es.bulk(body: payload)
    end
  end
end
