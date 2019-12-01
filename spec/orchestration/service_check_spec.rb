# frozen_string_literal: true

RSpec.describe Orchestration::ServiceCheck do
  subject(:service_check) { described_class.new(service, terminal, options) }

  let(:options) { {} }
  let(:service) do
    double(class: Orchestration::ServiceCheck, service_name: 'service')
  end

  let(:terminal) { double('Terminal') }

  it { is_expected.to be_a described_class }

  describe '#run' do
    subject(:run) { service_check.run }

    let(:connection_error) { ArgumentError } # Any class will do
    let(:service) do
      double(
        'service',
        connect: nil,
        echo_waiting: nil,
        echo_ready: nil,
        echo_failure: nil,
        echo_error: nil,
        service_name: 'rabbitmq',
        connection_errors: [connection_error],
        configuration: double(
          'Configuration',
          friendly_config: 'friendly config',
          configured?: true
        ),
        # Any class will do here; we're only testing text transformation on the
        # class name:
        class: Orchestration::Services::RabbitMQ::Healthcheck
      )
    end

    before do
      allow(I18n).to receive(:t) { 'text' }
      allow(terminal).to receive(:write)
    end

    it 'writes a startup message' do
      expect(terminal).to receive(:write).with(:rabbitmq, '', :status)
      run
    end

    it 'connects to service' do
      expect(service).to receive(:connect)
      run
    end

    it 'writes a waiting message' do
      expect(terminal).to receive(:write).with(:waiting, 'text')
      run
    end

    it 'writes a ready message' do
      expect(terminal).to receive(:write).with(:ready, 'text')
      run
    end

    describe 'error handling' do
      let(:options) { { attempt_limit: 20, retry_interval: 0.001 } }

      context 'expected errors' do
        let(:connection_error) do
          Orchestration::OrchestrationError
        end

        before do
          allow(service).to receive(:connect) do
            raise connection_error, 'message'
          end
        end

        it 'retries on expected errors' do
          expect(terminal)
            .to receive(:write)
            .with(:waiting, 'text')
            .exactly(20).times
          run
        end

        it 'outputs last error on failure' do
          expect(terminal)
            .to receive(:write)
            .with(:error, "[#{connection_error.name}] message")
          run
        end

        it 'outputs failure status on failure' do
          expect(terminal).to receive(:write).with(:failure, 'text')
          run
        end
      end

      context 'unexpected errors' do
        it 'raises unexpected errors' do
          allow(service).to receive(:connect) { raise NotImplementedError }
          expect { run }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end
