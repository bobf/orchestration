# frozen_string_literal: true

RSpec.describe Orchestration::Services::Mongo::Healthcheck do
  subject(:healthcheck) { described_class.new(env, terminal) }

  let(:env) do
    double(
      'Environment',
      environment: 'test',
      mongoid_configuration_path: fixture_path('mongoid')
    )
  end
  let(:terminal) { double('Terminal') }

  it { is_expected.to be_a described_class }

  describe '#start' do
    subject(:start) { healthcheck.start }

    it 'outputs a message' do
      expect(terminal)
        .to receive(:write)
        .with(:waiting, 'Waiting for mongo: [mongoid] localhost:27017')
      expect(terminal)
        .to receive(:write)
        .with(:ready, 'Mongo is ready.')

      start
    end
  end
end
