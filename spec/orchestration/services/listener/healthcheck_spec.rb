# frozen_string_literal: true

RSpec.describe Orchestration::Services::Listener::Healthcheck do
  subject(:healthcheck) { described_class.new(env, 'custom-service') }

  let(:env) do
    instance_double(
      Orchestration::Environment,
      settings: settings,
      docker_compose_path: fixture_path('docker-compose'),
      docker_compose_config: {
        'services' => { 'custom-service' => { 'ports' => ['3000:80'] } }
      }
    )
  end

  let(:settings) { instance_double(Orchestration::Settings) }

  it { is_expected.to be_a described_class }

  describe '.start' do
    subject(:start) { described_class.start(env, terminal, options) }

    let(:terminal) { double('Terminal') }
    let(:options) { { service_name: 'custom-service' } }

    before do
      allow(terminal).to receive(:write)
    end

    it 'outputs a waiting message' do
      expect(terminal)
        .to receive(:write)
        .with(:waiting, any_args)
      start
    end

    it 'outputs a ready message' do
      expect(terminal)
        .to receive(:write)
        .with(:waiting, any_args)
        .with(:ready, '[custom-service] is ready.')
      start
    end

    it 'attempts to connect to app' do
      expect(Net::HTTP).to receive(:start)

      start
    end

    describe 'connection errors' do
      let(:options) do
        {
          service_name: 'custom-service',
          retry_interval: 0,
          attempt_limit: 1,
          exit_on_error: false
        }
      end

      shared_examples 'an error handler' do
        before do
          allow(Net::HTTP).to receive(:start) { raise error }
        end

        it 'handles connection errors' do
          expect { start }.to_not raise_error
        end
      end

      context 'connection refused' do
        let(:error) { Errno::ECONNREFUSED }
        it_behaves_like 'an error handler'
      end

      context 'address not available' do
        let(:error) { Errno::EADDRNOTAVAIL }
        it_behaves_like 'an error handler'
      end
    end
  end
end
