# frozen_string_literal: true

RSpec.describe HomeflowOrchestration::Services::Database::Healthcheck do
  subject(:healthcheck) { described_class.new(env) }

  let(:env) do
    double(
      'Environment',
      environment: 'test',
      database_url: nil,
      database_configuration_path: fixture_path('sqlite3')
    )
  end

  it { is_expected.to be_a described_class }

  describe '.start' do
    let(:terminal) { double('Terminal') }

    subject(:start) { described_class.start(env, terminal) }

    before do
      database_url = 'sqlite3://database.db'
      allow(env).to receive(:database_url) { database_url }
      allow(env).to receive(:environment) { 'test' }
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DATABASE_URL') { database_url }
      allow(ActiveRecord::Base).to receive(:establish_connection)
      allow(ActiveRecord::Base).to receive(:connection)
      allow(terminal).to receive(:write)
    end

    it 'outputs a message' do
      expect(terminal)
        .to receive(:write)
        .with(:waiting, 'Waiting for database: [sqlite3]')
      expect(terminal)
        .to receive(:write)
        .with(:ready, 'Database is ready.')

      start
    end

    it 'attempts to connect to database' do
      expect(ActiveRecord::Base).to receive(:connection)

      start
    end
  end
end
