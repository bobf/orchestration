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
    subject(:start) { described_class.start(env, terminal, options) }

    let(:options) { {} }

    before do
      allow(terminal).to receive(:write)
    end

    it 'outputs a ready message' do
      allow(Bunny).to receive(:new) { double(start: nil, stop: nil) }
      expect(terminal)
        .to receive(:write)
        .with(:waiting, 'Waiting for RabbitMQ: [bunny] amqp://localhost:5673')

      start
    end

    it 'outputs a waiting message' do
      allow(Bunny).to receive(:new) { double(start: nil, stop: nil) }
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

    describe 'connection errors' do
      let(:options) do
        { retry_interval: 0, attempt_limit: 1, exit_on_error: false }
      end

      shared_examples 'an error handler' do
        let(:bunny) { double('Bunny connection') }
        before do
          allow(Bunny).to receive(:new) { bunny }
          allow(bunny).to receive(:start) { raise error }
        end

        it 'handles failed connections' do
          expect { start }.to_not raise_error
        end
      end

      context 'connection failed' do
        let(:error) { Bunny::TCPConnectionFailedForAllHosts }
        it_behaves_like 'an error handler'
      end

      context 'empty response' do
        let(:error) { AMQ::Protocol::EmptyResponseError }
        it_behaves_like 'an error handler'
      end
    end
  end
end
