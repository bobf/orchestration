# frozen_string_literal: true

RSpec.describe Orchestration::Services::Listener::Configuration do
  subject(:configuration) do
    described_class.new(env, 'custom-service', options)
  end

  let(:config) { fixture('docker-compose.yml') }
  let(:options) { {} }
  let(:env) do
    instance_double(
      Orchestration::Environment,
      environment: 'test',
      docker_compose_path: config,
      docker_compose_config: docker_compose_config
    )
  end

  let(:docker_compose_config) do
    {
      'services' => {
        'custom-service' => {
          'image' => image,
          'ports' => ['3000:80']
        }
      }
    }
  end

  let(:image) { nil }

  it { is_expected.to be_a described_class }
  its(:friendly_config) { is_expected.to eql '[custom-service] 127.0.0.1:3000' }

  context 'with image' do
    let(:image) { 'library/example' }
    its(:friendly_config) { is_expected.to include '[library/example]' }
  end

  context 'sidecar' do
    let(:options) { { sidecar: true } }
    its(:port) { is_expected.to eql 80 }
    its(:host) { is_expected.to eql 'custom-service' }
  end

  context 'sidecar' do
    let(:options) { { sidecar: false } }
    its(:port) { is_expected.to eql 3000 }
    its(:host) { is_expected.to eql '127.0.0.1' }
  end
end
