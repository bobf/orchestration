# frozen_string_literal: true

RSpec.describe Orchestration::Services::RabbitMQ::Healthcheck do
  subject(:healthcheck) { described_class.new(env) }

  let(:env) do
    double(
      'Environment',
      environment: 'test',
      rabbitmq_configuration_path: fixture_path('rabbitmq')
    )
  end

  let(:terminal) { double('Terminal') }

  it { is_expected.to be_a described_class }

  describe '.start' do
    subject(:start) { described_class.start(env, terminal) }

    before do
      allow(terminal).to receive(:write)
    end

    it 'outputs a message' do
      allow(Bunny).to receive(:new) { double(start: nil, stop: nil) }
      expect(terminal)
        .to receive(:write)
        .with(:waiting, 'Waiting for RabbitMQ: [bunny] amqp://localhost:5673')
      expect(terminal)
        .to receive(:write)
        .with(:ready, 'RabbitMQ is ready.')

      start
    end

    it 'connects to rabbitmq' do
      bunny = double('Bunny', stop: nil)
      allow(Bunny).to receive(:new) { bunny }
      expect(bunny).to receive(:start)

      start
    end
  end
end
