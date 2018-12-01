# frozen_string_literal: true

RSpec.describe Orchestration::Services::NginxProxy::Configuration do
  subject(:configuration) { described_class.new(env) }

  let(:config) { fixture_path('docker-compose.yml') }
  let(:env) do
    instance_double(
      Orchestration::Environment,
      docker_compose_configuration_path: config
    )
  end

  it { is_expected.to be_a described_class }
  its(:friendly_config) { is_expected.to eql '[nginx-proxy]' }
end
