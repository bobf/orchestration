# frozen_string_literal: true

RSpec.describe Orchestration::Services::Redis::Healthcheck do
  subject(:healthcheck) { described_class.new(env) }

  let(:env) do
    double(
      'Environment',
      environment: 'test',
      redis_configuration_path: fixture_path('rabbitmq'),
      redis_url: nil,
      docker_compose_config: {
        'services' => { 'redis' => { 'ports' => ['3769:6379'] } }
      }
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

    it 'outputs a waiting message' do
      allow(Redis).to receive(:new) { double(connected?: true) }
      expect(terminal)
        .to receive(:write)
        .with(:waiting, any_args)

      start
    end

    it 'outputs a ready message' do
      allow(Redis).to receive(:new) { double(connected?: true) }
      expect(terminal)
        .to receive(:write)
        .with(:ready, 'redis is ready')

      start
    end

    it 'tests redis connection' do
      redis = double('Bunny', connected?: true)
      allow(Redis).to receive(:new) { redis }
      expect(redis).to receive(:connected?)

      start
    end

    describe 'connection errors' do
      let(:options) do
        { retry_interval: 0, attempt_limit: 1, exit_on_error: false }
      end

      shared_examples 'an error handler' do
        let(:redis) { double('Redis connection') }
        before do
          allow(Redis).to receive(:new) { redis }
          allow(redis).to receive(:connected?) { false }
        end

        it 'handles failed connections' do
          expect { start }.to_not raise_error
        end
      end

      context 'connection failed' do
        let(:error) { Orchestration::Services::Redis::Healthcheck::NotConnectedError }
        it_behaves_like 'an error handler'
      end
    end
  end
end
