# frozen_string_literal: true

RSpec.describe HomeflowOrchestration::Services::Mongo::Healthcheck do
  subject(:healthcheck) { described_class.new(env) }

  let(:env) do
    double(
      'Environment',
      environment: 'test',
      mongoid_configuration_path: fixture_path('mongoid')
    )
  end

  it { is_expected.to be_a described_class }

  describe '.start' do
    subject(:start) { described_class.start(env, terminal) }

    let(:terminal) { double('Terminal') }

    before do
      allow(Mongoid).to receive(:default_client) { double(database_names: [1]) }
      allow(terminal).to receive(:write)
    end

    it 'outputs a message' do
      expect(terminal)
        .to receive(:write)
        .with(:waiting, 'Waiting for Mongo: [mongoid] localhost:27017')
      expect(terminal)
        .to receive(:write)
        .with(:ready, 'Mongo is ready.')

      start
    end

    it 'connects to mongo' do
      expect(Mongoid).to receive(:default_client)

      start
    end
  end
end
