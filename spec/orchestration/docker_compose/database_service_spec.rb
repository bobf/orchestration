# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::DatabaseService do
  subject(:database_service) { described_class.new(configuration) }

  let(:adapter) { 'sqlite3' }
  let(:env) do
    instance_double(
      Orchestration::Environment,
      application_name: 'dummy',
      environment: 'test',
      database_url: nil,
      docker_compose_config?: false,
      database_volume: 'dummy_database',
      database_configuration_path: fixture_path(adapter)
    )
  end

  let(:configuration) do
    Orchestration::Services::Database::Configuration.new(env)
  end

  describe '#definition' do
    subject(:definition) { database_service.definition }

    context 'postgresql' do
      let(:adapter) { 'postgresql' }

      it { is_expected.to be_a Hash }
      its(['image']) { is_expected.to eql 'library/postgres' }
      its(['volumes']) { is_expected.to eql ['dummy_database:/var/pgdata'] }
      its(['environment']) do
        is_expected.to eql(
          'PGPORT' => '3354',
          'POSTGRES_PASSWORD' => 'password',
          'PGDATA' => '/var/pgdata'
        )
      end
    end

    context 'mysql2' do
      let(:adapter) { 'mysql2' }

      it { is_expected.to be_a Hash }
      its(['image']) { is_expected.to eql 'library/mysql' }
      its(['volumes']) { is_expected.to eql ['dummy_database:/var/lib/mysql'] }
      its(['environment']) do
        is_expected.to eql(
          'MYSQL_ROOT_PASSWORD' => 'password',
          'MYSQL_TCP_PORT' => '3354'
        )
      end
    end

    context 'sqlite3' do
      let(:adapter) { 'sqlite3' }

      it { is_expected.to be_nil }
    end
  end
end
