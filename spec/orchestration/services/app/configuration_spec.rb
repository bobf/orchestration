# frozen_string_literal: true

RSpec.describe Orchestration::Services::App::Configuration do
  subject(:configuration) { described_class.new(env) }

  let(:env) do
    instance_double(
      Orchestration::Environment,
      docker_compose_path: fixture_path('docker-compose'),
      database_configuration_path: fixture_path('mysql2'),
      environment: 'development',
      database_url: nil,
      app_name: 'testapp',
      app_port: 3456,
      settings: instance_double(Orchestration::Settings),
      docker_compose_config?: true,
      docker_compose_config: {
        'services' => {
          'app' => { 'ports' => ['3456:8080'] },
          'database' => { 'ports' => ['3360:3354'] }
        }
      }
    )
  end

  before do
    allow(env.settings).to receive(:get).with('docker.repository') { 'repo' }
    allow(env.settings)
      .to receive(:get)
        .with('docker.organization') { 'testuser' }
  end

  it { is_expected.to be_a described_class }
  its(:docker_organization) { is_expected.to eql 'testuser' }
  its(:app_name) { is_expected.to eql 'repo' }
  its(:friendly_config) { is_expected.to eql '[repo] 127.0.0.1:3456' }
  its(:host) { is_expected.to eql '127.0.0.1' }
  its(:port) { is_expected.to eql 3456 }
  its(:database_settings) { is_expected.to be_a Hash }
  its(:database_url) do
    is_expected.to eql 'mysql2://root:password@localhost:3360/development_db'
  end
end
