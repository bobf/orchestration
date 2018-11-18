# frozen_string_literal: true

RSpec.describe Orchestration::Services::RabbitMQ::Configuration do
  subject(:configuration) { described_class.new(env) }

  let(:config) { fixture_path('rabbitmq') }
  let(:environment) { 'test' }
  let(:env) do
    double(
      'Environment',
      environment: environment,
      rabbitmq_configuration_path: config
    )
  end

  it { is_expected.to be_a described_class }

  describe '#settings' do
    subject(:settings) { configuration.settings }

    it { is_expected.to eql('host' => 'localhost', 'port' => 5673) }
  end

  describe '#friendly_config' do
    subject(:friendly_config) { configuration.friendly_config }

    it { is_expected.to eql '[bunny] amqp://localhost:5673' }

    context 'development environment (default port)' do
      let(:environment) { 'development' }
      it { is_expected.to eql '[bunny] amqp://example.com:5672' }
    end
  end
end
