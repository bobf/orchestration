# frozen_string_literal: true

RSpec.describe Orchestration::Services::Database::Healthcheck do
  subject(:healthcheck) { described_class.new(env) }
  let(:env) do
    double(
      'Environment',
      environment: 'test',
      database_url: nil,
      database_configuration_path: database_config_path
    )
  end

  let(:database_config_path) { fixture_path('sqlite3') }

  it { is_expected.to be_a described_class }

  describe '.start' do
    subject(:start) { described_class.start(env, terminal) }

    let(:terminal) { double('Terminal') }

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

  describe 'connection errors' do
    shared_examples 'an error handler' do
      subject(:start) { described_class.start(env, terminal, options) }
      let(:terminal) { double('Terminal', write: nil) }

      let(:options) do
        { retry_interval: 0, attempt_limit: 1, exit_on_error: false }
      end

      before do
        allow(ActiveRecord::Base).to receive(:connection) { raise error }
      end

      it 'handles connection errors' do
        expect { start }.to_not raise_error
      end
    end

    context 'connection failed' do
      let(:error) { ActiveRecord::ConnectionNotEstablished }
      it_behaves_like 'an error handler'
    end

    context 'Mysql2 error' do
      let(:error) { Mysql2::Error.new('message') }
      let(:database_config_path) { fixture_path('mysql2') }
      it_behaves_like 'an error handler'
    end

    context 'PG connection bad error' do
      let(:error) { PG::ConnectionBad }
      let(:database_config_path) { fixture_path('postgresql') }
      it_behaves_like 'an error handler'
    end
  end
end
