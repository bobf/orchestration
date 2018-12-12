# frozen_string_literal: true

RSpec.describe Orchestration::Services::Mongo::Healthcheck do
  subject(:healthcheck) { described_class.new(env) }

  let(:env) do
    double(
      'Environment',
      environment: 'test',
      mongoid_configuration_path: fixture_path('mongoid'),
      docker_compose_config: {
        'services' => { 'mongo' => { 'ports' => ['27020:27017'] } }
      }
    )
  end

  it { is_expected.to be_a described_class }

  describe '.start' do
    subject(:start) { described_class.start(env, terminal, options) }

    let(:terminal) { double('Terminal') }
    let(:options) { {} }

    before do
      allow(Mongoid).to receive(:default_client) { double(database_names: [1]) }
      allow(terminal).to receive(:write)
    end

    it 'outputs a waiting message' do
      expect(terminal)
        .to receive(:write)
        .with(:waiting, 'Waiting for Mongo: [mongoid] 127.0.0.1:27020/test_db')

      start
    end

    it 'outputs a ready message' do
      expect(terminal)
        .to receive(:write)
        .with(:ready, 'Mongo is ready.')

      start
    end

    it 'connects to mongo' do
      expect(Mongoid).to receive(:default_client)

      start
    end

    describe 'connection errors' do
      let(:options) do
        { retry_interval: 0, attempt_limit: 1, exit_on_error: false }
      end

      shared_examples 'an error handler' do
        before do
          allow(Mongoid).to receive(:default_client) { raise error }
        end

        it 'handles connection errors' do
          expect { start }.to_not raise_error
        end
      end

      context 'no server available' do
        let(:error_info) do
          double(
            server_selection_timeout: nil,
            local_threshold: nil
          )
        end

        let(:error) { ::Mongo::Error::NoServerAvailable.new(error_info) }
        it_behaves_like 'an error handler'
      end
    end
  end
end
