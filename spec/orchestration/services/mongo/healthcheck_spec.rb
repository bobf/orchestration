# frozen_string_literal: true

RSpec.describe Orchestration::Services::Mongo::Healthcheck do
  subject(:healthcheck) { described_class.new(env) }

  let(:env) do
    double(
      'Environment',
      environment: 'test',
      mongoid_configuration_path: fixture_path('mongoid'),
      mongo_url: nil,
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
    let!(:mongo_stub) do
      stub_request(:get, 'http://127.0.0.1:27020/').and_return(status: 200)
    end

    before do
      allow(terminal).to receive(:write)
    end

    it 'outputs a waiting message' do
      expect(terminal)
        .to receive(:write)
        .with(:waiting, 'Waiting for Mongo: [mongoid] mongodb://127.0.0.1:27020/config_db')

      start
    end

    it 'outputs a ready message' do
      expect(terminal)
        .to receive(:write)
        .with(:ready, 'Mongo is ready.')

      start
    end

    it 'connects to mongo' do
      start
      expect(mongo_stub).to have_been_requested
    end

    describe 'connection errors' do
      let(:options) do
        { retry_interval: 0, attempt_limit: 1, exit_on_error: false }
      end

      shared_examples 'an error handler' do
        before do
          stub_request(:get, 'http://127.0.0.1/') { raise error }
        end

        it 'handles connection errors' do
          expect { start }.to_not raise_error
        end
      end

      context 'no server available' do
        let(:error) { Errno::ECONNREFUSED }
        it_behaves_like 'an error handler'
      end
    end
  end
end
