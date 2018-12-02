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
      docker_compose_config: {
        'services' => { 'rabbitmq' => { 'ports' => ['5673:5672'] } }
      }
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
      it { is_expected.to eql '[bunny] amqp://localhost:5673' }
    end
  end
end
