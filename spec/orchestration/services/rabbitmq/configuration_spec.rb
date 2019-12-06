# frozen_string_literal: true

RSpec.describe Orchestration::Services::RabbitMQ::Configuration do
  subject(:configuration) { described_class.new(env) }

  let(:config) { fixture_path('rabbitmq') }
  let(:environment) { 'test' }
  let(:env) do
    double(
      'Environment',
      environment: environment,
      rabbitmq_configuration_path: config,
      rabbitmq_url: nil,
      docker_compose_config: {
        'services' => { 'rabbitmq' => { 'ports' => ['${sidecar-5673:}5672'] } }
      }
    )
  end

  it { is_expected.to be_a described_class }

  context 'development environment' do
    let(:environment) { 'development' }
    its(:host) { is_expected.to eql '127.0.0.1' }
    its(:port) { is_expected.to eql 5673 }
    its(:friendly_config) { is_expected.to eql '[bunny] amqp://127.0.0.1:5673' }
  end

  context 'test environment' do
    let(:environment) { 'test' }
    its(:host) { is_expected.to eql '127.0.0.1' }
    its(:port) { is_expected.to eql 5673 }
    its(:friendly_config) { is_expected.to eql '[bunny] amqp://127.0.0.1:5673' }
  end

  context 'production environment' do
    let(:environment) { 'production' }
    its(:host) { is_expected.to eql 'rabbitmq' }
    its(:port) { is_expected.to eql 5672 }
    its(:friendly_config) { is_expected.to eql '[bunny] amqp://rabbitmq:5672' }
  end

  context 'RABBITMQ_URL' do
    let(:environment) { 'production' }
    before { allow(env).to receive(:rabbitmq_url) { 'amqp://my:1234' } }
    its(:host) { is_expected.to eql 'my' }
    its(:port) { is_expected.to eql 1234 }
    its(:friendly_config) { is_expected.to eql '[bunny] amqp://my:1234' }
  end
end
