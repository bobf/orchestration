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
      settings: instance_double(Orchestration::Settings),
      docker_compose_config?: true,
      docker_compose_config: {
        'services' => {
          'nginx_proxy' => { 'ports' => ['3000:80'] },
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
  its(:friendly_config) { is_expected.to eql '[repo] 127.0.0.1:3000' }
  its(:local_port) { is_expected.to eql 3000 }
  its(:database_settings) { is_expected.to be_a Hash }
  its(:database_url) do
    is_expected.to eql 'mysql2://root:password@database:3354/mysql'
  end
end
