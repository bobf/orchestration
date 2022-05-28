# frozen_string_literal: true

RSpec.describe Orchestration::Services::Redis::Configuration do
  subject(:configuration) { described_class.new(env) }

  let(:config) { fixture_path('redis') }
  let(:environment) { 'test' }
  let(:env) do
    double(
      'Environment',
      environment:,
      redis_configuration_path: config,
      redis_url: nil,
      docker_compose_config: {
        'services' => { 'redis' => { 'ports' => ['${sidecar-3769:}6379'] } }
      }
    )
  end

  it { is_expected.to be_a described_class }

  context 'development environment' do
    let(:environment) { 'development' }
    its(:host) { is_expected.to eql '127.0.0.1' }
    its(:port) { is_expected.to eql 3769 }
    its(:friendly_config) { is_expected.to eql '[redis] redis://127.0.0.1:3769' }
  end

  context 'test environment' do
    let(:environment) { 'test' }
    its(:host) { is_expected.to eql '127.0.0.1' }
    its(:port) { is_expected.to eql 3769 }
    its(:friendly_config) { is_expected.to eql '[redis] redis://127.0.0.1:3769' }
  end

  context 'RABBITMQ_URL' do
    let(:environment) { 'production' }
    before { allow(env).to receive(:redis_url) { 'redis://my:1234' } }
    its(:host) { is_expected.to eql 'my' }
    its(:port) { is_expected.to eql 1234 }
    its(:friendly_config) { is_expected.to eql '[redis] redis://my:1234' }
  end
end
