# frozen_string_literal: true

RSpec.describe Orchestration::Services::Application::Configuration do
  subject(:configuration) { described_class.new(env) }

  let(:env) do
    instance_double(
      Orchestration::Environment,
      docker_compose_configuration_path: fixture_path('docker-compose'),
      database_configuration_path: fixture_path('mysql2'),
      environment: 'development',
      database_url: nil,
      application_name: 'testapp',
      settings: instance_double(Orchestration::Settings),
      docker_compose_config: {
        'services' => { 'nginx-proxy' => { 'ports' => ['3000:80'] } }
      }
    )
  end

  before do
    allow(env.settings).to receive(:get).with('docker.username') { 'testuser' }
  end

  it { is_expected.to be_a described_class }
  its(:docker_username) { is_expected.to eql 'testuser' }
  its(:application_name) { is_expected.to eql 'testapp' }
  its(:friendly_config) { is_expected.to eql '[testapp] 127.0.0.1:3000' }
  its(:local_port) { is_expected.to eql 3000 }
  its(:database_settings) { is_expected.to be_a Hash }
  its(:database_url) do
    is_expected.to eql 'mysql2://root:password@database:3354/mysql'
  end
end
