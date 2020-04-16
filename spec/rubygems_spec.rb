require 'spec_helper'
require 'climate_control'
require_relative '../lib/rubygems.rb'

describe Rubygems do
  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end

  context "instantiation" do
    let(:client) { described_class.new }

    it 'creates a sequel client when Postgresql is set' do
      allow(Sequel).to receive(:connect).and_return('connection')
      with_modified_env(DATABASE_URL: 'postgres::/localhost/gems') do
        expect(client.instance_variable_get(:@db)).to eq 'connection'
        expect(client.instance_variable_get(:@es)).to be_nil
      end
    end

    it 'creates an Elasticsearch client when URL is set' do
      with_modified_env(ELASTICSEARCH_URL: 'http://localhost:9200') do
        expect(client.instance_variable_get(:@db)).to be_nil
        es = client.instance_variable_get(:@es)
        expect(es).not_to be_nil
        expect(es.transport.hosts.first[:host]).to eq 'localhost'
        expect(es.transport.hosts.first[:port]).to eq 9200
      end
    end

    it 'creates an Elasticsearch client when Cloud credentials are set' do
      with_modified_env(
        ELASTICSEARCH_USERNAME: 'elastic',
        ELASTICSEARCH_PASSWORD: 'password',
        ELASTIC_CLOUD_ID: 'cloud_id'
      ) do
        expect(client.instance_variable_get(:@db)).to be_nil
        es = client.instance_variable_get(:@es)
        expect(es).not_to be_nil
        expect(es.transport.options[:cloud_id]).to eq 'cloud_id'
        expect(es.transport.hosts.first[:protocol]).to eq 'https'
        expect(es.transport.hosts.first[:port]).to eq 9243
      end
    end
  end
end
