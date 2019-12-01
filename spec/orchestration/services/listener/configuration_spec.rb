# frozen_string_literal: true

RSpec.describe Orchestration::Services::Listener::Configuration do
  subject(:configuration) { described_class.new(env, 'custom-service') }

  let(:config) { fixture_path('docker-compose.yml') }
  let(:env) do
    instance_double(
      Orchestration::Environment,
      environment: 'test',
      docker_compose_path: config,
      docker_compose_config: {
        'services' => { 'custom-service' => { 'ports' => ['3000:80'] } }
      }
    )
  end

  it { is_expected.to be_a described_class }
  its(:friendly_config) { is_expected.to eql '[custom-service] 127.0.0.1:3000' }
end
