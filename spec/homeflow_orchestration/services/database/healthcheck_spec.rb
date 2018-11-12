# frozen_string_literal: true

RSpec.describe Orchestration::Services::Database::Healthcheck do
  let(:terminal) { double('terminal') }

  subject(:healthcheck) { described_class.new(terminal) }

  it { is_expected.to be_a described_class }

  describe '#start' do
    subject(:start) { healthcheck.start }

    before do
      url = 'sqlite3://database.db'
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DATABASE_URL') { url }
      allow(ActiveRecord::Base).to receive(:establish_connection)
      allow(ActiveRecord::Base).to receive(:connection)
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
      allow(terminal).to receive(:write)
      expect(ActiveRecord::Base).to receive(:connection)

      start
    end
  end
end
