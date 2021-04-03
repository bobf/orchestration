# frozen_string_literal: true

RSpec.describe Orchestration::Services::Database::Healthcheck do
  subject(:healthcheck) { described_class.new(env) }
  let(:env) do
    double(
      'Environment',
      environment: 'test',
      database_url: nil,
      database_configuration_path: database_config_path,
      docker_compose_config?: true,
      docker_compose_config: {
        'services' => { 'database' => { 'ports' => ['5499:5499'] } }
      }
    )
  end

  before do
    stub_const('ENV', ENV.to_h.merge('DATABASE_URL' => database_url))
    stub_const('ENV', ENV.to_h.merge('TEST_DATABASE_URL' => database_url))
  end

  let(:database_url) { nil }
  let(:database_config_path) { fixture_path('sqlite3') }

  it { is_expected.to be_a described_class }

  describe '.start' do
    subject(:start) { described_class.start(env, terminal) }

    let(:terminal) { double('Terminal') }
    let(:database_url) { 'sqlite3://database.db' }

    before do
      allow(env).to receive(:environment) { 'test' }
      allow(ActiveRecord::Base).to receive(:establish_connection)
      allow(ActiveRecord::Base).to receive(:connection)
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
        .with(:ready, 'database is ready')

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
      let(:database_url) { 'mysql://127.0.0.1:3306' }
      it_behaves_like 'an error handler'
    end

    context 'PG connection bad error' do
      let(:database_url) { 'postgresql://127.0.0.1:5342' }
      let(:error) { PG::ConnectionBad }
      it_behaves_like 'an error handler'
    end
  end
end
