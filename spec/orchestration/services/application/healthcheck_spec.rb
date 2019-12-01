# frozen_string_literal: true

RSpec.describe Orchestration::Services::Application::Healthcheck do
  subject(:healthcheck) { described_class.new(env) }

  let(:env) do
    instance_double(
      Orchestration::Environment,
      settings: settings,
      application_name: 'test_app',
      docker_compose_configuration_path: fixture_path('docker-compose'),
      docker_compose_config: {
        'services' => { 'nginx-proxy' => { 'ports' => ['3000:80'] } }
      }
    )
  end

  let(:settings) do
    instance_double(Orchestration::Settings)
  end

  before do
    allow(settings).to receive(:get).with('docker.username') { 'dockeruser' }
    allow(settings).to receive(:get).with('docker.repository') { 'repo' }
  end

  it { is_expected.to be_a described_class }

  describe '.start' do
    subject(:start) { described_class.start(env, terminal, options) }

    let(:terminal) { double('Terminal') }
    let(:options) { {} }

    before do
      allow(terminal).to receive(:write)
      @stub = stub_request(:get, 'http://localhost:3000')
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
        .with(:ready, 'Application is ready.')

      start
    end

    it 'attempts to connect to application' do
      start
      expect(@stub).to have_been_requested
    end

    describe 'connection errors' do
      let(:options) do
        { retry_interval: 0, attempt_limit: 1, exit_on_error: false }
      end

      before { @stub = stub_request(:get, 'http://localhost:3000') }

      shared_examples 'an error handler' do
        it 'outputs a waiting message' do
          expect(terminal).to receive(:write).with(:waiting, any_args)
          start
        end

        it 'outputs an error message' do
          expect(terminal)
            .to receive(:write)
            .with(:error, any_args)
          start
        end

        it 'swallows errors' do
          expect { start }.to_not raise_error
        end
      end

      context '503 service unavailable' do
        before { @stub.to_return(status: 503) }
        it_behaves_like 'an error handler'
      end

      context '502 bad gateway' do
        before { @stub.to_return(status: 502) }
        it_behaves_like 'an error handler'
      end

      context 'connection refused' do
        before { @stub.to_return { raise Errno::ECONNREFUSED } }
        it_behaves_like 'an error handler'
      end
    end
  end
end
