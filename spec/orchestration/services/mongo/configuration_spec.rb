# frozen_string_literal: true

RSpec.describe Orchestration::Services::Mongo::Configuration do
  subject(:configuration) { described_class.new(env) }

  let(:environment) { 'development' }
  let(:env) do
    double(
      'Environment',
      environment: environment,
      mongoid_configuration_path: '/path/to/nowhere.yml',
      mongo_url: nil,
      docker_compose_config: {
        'services' => { 'mongo' => { 'ports' => ['${sidecar-27018:}27017'] } }
      }
    )
  end

  it { is_expected.to be_a described_class }

  context 'development environment' do
    let(:environment) { 'development' }
    its(:host) { is_expected.to eql '127.0.0.1' }
    its(:port) { is_expected.to eql 27_018 }
    its(:friendly_config) do
      is_expected.to eql '[mongoid] mongodb://127.0.0.1:27018/developmentdb'
    end
  end

  context 'test environment' do
    let(:environment) { 'test' }
    its(:host) { is_expected.to eql '127.0.0.1' }
    its(:port) { is_expected.to eql 27_018 }
    its(:friendly_config) do
      is_expected.to eql '[mongoid] mongodb://127.0.0.1:27018/testdb'
    end
  end

  context 'config file' do
    let(:environment) { 'test' }
    let(:path) { fixture_path('mongoid') }
    before { allow(env).to receive(:mongoid_configuration_path) { path } }
    its(:database) { is_expected.to eql 'config_db' }
  end
end
