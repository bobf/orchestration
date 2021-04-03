# frozen_string_literal: true

RSpec.describe Orchestration::Services::Database::Configuration do
  subject(:configuration) { described_class.new(env, 'database', options) }

  let(:options) { {} }
  let(:database_url) { nil }

  let(:config_path) do
    Orchestration.root.join('spec', 'dummy', 'config', 'database.yml')
  end

  before do
    stub_const('ENV', ENV.to_h.merge('TEST_DATABASE_URL' => database_url))
  end

  let(:env) do
    instance_double(
      Orchestration::Environment,
      database_url: nil,
      environment: 'test',
      database_configuration_path: config_path,
      docker_compose_config?: true,
      docker_compose_config: {
        'services' => { 'database' => { 'ports' => ['${sidecar-3354:}3354'] } }
      }
    )
  end

  it { is_expected.to be_a described_class }

  describe '#console_command' do
    subject(:console_command) { configuration.console_command }

    context 'sqlite3' do
      let(:config_path) { fixture('sqlite3.yml').path }
      it { is_expected.to eql 'sqlite3 db/test.sqlite3' }
    end

    context 'postgresql' do
      let(:config_path) { fixture('postgresql.yml').path }
      let(:expected) do
        "PGPASSWORD='password' psql --username=postgres --host=localhost --port=5432 --dbname=test_db"
      end
      it { is_expected.to eql expected }
    end

    context 'mysql' do
      let(:config_path) { fixture('mysql2.yml').path }
      let(:expected) do
        'mysql --user=root --port=3354 --host=127.0.0.1 --password=password --no-auto-rehash test_db'
      end
      it { is_expected.to eql expected }
    end
  end

  describe '#friendly_config' do
    subject(:friendly_config) { configuration.friendly_config }

    context 'sqlite3' do
      let(:config_path) { fixture('sqlite3.yml').path }
      it { is_expected.to eql '[sqlite3]' }
    end

    context 'postgresql' do
      let(:config_path) { fixture('postgresql.yml').path }
      it { is_expected.to eql '[postgresql] postgresql://postgres:password@localhost:5432/test_db' }
    end

    context 'mysql' do
      let(:config_path) { fixture('mysql2.yml').path }
      it { is_expected.to eql '[mysql2] mysql2://root:password@127.0.0.1:3354/test_db' }
    end
  end

  describe '#settings' do
    subject(:settings) { configuration.settings(healthcheck: healthcheck) }

    let(:healthcheck) { false }

    context 'sqlite3' do
      let(:config_path) { fixture('sqlite3.yml').path }

      its(['adapter']) { is_expected.to eql 'sqlite3' }
      its(['host']) { is_expected.to eql '127.0.0.1' }
      its(['database']) { is_expected.to eql 'db/test.sqlite3' }
      its(['username']) { is_expected.to eql '' }
      its(['password']) { is_expected.to eql '' }
    end

    context 'postgresql' do
      let(:config_path) { fixture('postgresql.yml').path }

      its(['adapter']) { is_expected.to eql 'postgresql' }
      its(['host']) { is_expected.to eql 'localhost' }
      its(['database']) { is_expected.to eql 'test_db' }
      its(['username']) { is_expected.to eql 'postgres' }
      its(['password']) { is_expected.to eql 'password' }
      its(['port']) { is_expected.to eql 5432 }
      context 'healthcheck' do
        let(:healthcheck) { true }
        its(['database']) { is_expected.to eql 'postgres' }
      end
    end

    context 'mysql2' do
      let(:config_path) { fixture('mysql2.yml').path }

      its(['adapter']) { is_expected.to eql 'mysql2' }
      its(['host']) { is_expected.to eql '127.0.0.1' }
      its(['database']) { is_expected.to eql 'test_db' }
      its(['username']) { is_expected.to eql 'root' }
      its(['password']) { is_expected.to eql 'password' }

      context 'healthcheck' do
        let(:healthcheck) { true }
        its(['database']) { is_expected.to eql 'mysql' }
      end
    end

    context 'from DATABASE_URL environment variable' do
      let(:config_path) { fixture('postgresql.yml').path }

      before do
        allow(env).to receive(:database_url) { database_url }
      end

      context 'host override' do
        let(:database_url) { 'postgresql://localhost' }

        its(['adapter']) { is_expected.to eql 'postgresql' }
        its(['host']) { is_expected.to eql 'localhost' }
        its(['database']) { is_expected.to eql 'test_db' }
        its(['username']) { is_expected.to eql 'postgres' }
        its(['password']) { is_expected.to eql 'password' }
      end

      context 'port override' do
        let(:database_url) { 'postgresql://:5678' }

        its(['adapter']) { is_expected.to eql 'postgresql' }
        its(['host']) { is_expected.to eql 'localhost' }
        its(['database']) { is_expected.to eql 'test_db' }
        its(['username']) { is_expected.to eql 'postgres' }
        its(['password']) { is_expected.to eql 'password' }
        its(['port']) { is_expected.to eql 5678 }
      end
    end

    context 'from environment (RAILS_ENV, RACK_ENV)' do
      let(:config_path) { fixture('postgresql.yml').path }

      before do
        allow(env).to receive(:environment) { 'production' }
      end

      its(['adapter']) { is_expected.to eql 'postgresql' }
      its(['host']) { is_expected.to eql 'database.company.org' }
      its(['database']) { is_expected.to eql 'production_db' }
      its(['username']) { is_expected.to eql 'postgres' }
      its(['password']) { is_expected.to eql 'password' }
    end

    context 'from alternate database.yml' do
      let(:options) { { config_path: fixture('database.custom.yml').path } }
      let(:config_path) { fixture('mysql2.yml').path }

      its(['adapter']) { is_expected.to eql 'postgresql' }
    end

    context 'not from alternate database.yml' do
      let(:config_path) { fixture('mysql2.yml').path }

      its(['adapter']) { is_expected.to_not eql 'custom' }
    end
  end
end
