# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::DatabaseService do
  subject(:database_service) { described_class.new(configuration, environment) }

  let(:adapter) { 'sqlite3' }
  let(:environment) { :test }
  let(:env) do
    instance_double(
      Orchestration::Environment,
      app_name: 'dummy',
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
      let(:environment) { :production }
      before { hide_const('Mysql2') }

      it { is_expected.to be_a Hash }
      its(['image']) { is_expected.to eql 'library/postgres' }
      its(['environment']) do
        is_expected.to eql(
          'POSTGRES_PASSWORD' => 'password',
          'PGDATA' => '/var/pgdata'
        )
      end
    end

    context 'mysql2' do
      let(:adapter) { 'mysql2' }
      let(:environment) { :production }
      before { hide_const('PG') }

      it { is_expected.to be_a Hash }
      its(['image']) { is_expected.to eql 'library/mysql' }
      its(['environment']) do
        is_expected.to eql(
          'MYSQL_ROOT_PASSWORD' => 'password'
        )
      end
    end

    context 'sqlite3' do
      let(:adapter) { 'sqlite3' }
      before { hide_const('Mysql2') }
      before { hide_const('PG') }

      it { is_expected.to be_nil }
    end

    context 'production' do
      let(:environment) { :production }
      let(:adapter) { 'postgresql' }
      it { is_expected.to include 'volumes' }
      it { is_expected.to_not include 'ports' }
    end

    context 'test' do
      let(:environment) { :test }
      let(:adapter) { 'postgresql' }
      before { hide_const('Mysql2') }
      its(['volumes']) { is_expected.to be_nil }
      describe 'local port' do
        subject(:port) { definition['ports'].first.partition(':').first.to_i }
        it { is_expected.to be_positive } # Randomly generated
      end

      describe 'remote port' do
        subject(:port) { definition['ports'].first.partition(':').last.to_i }
        it { is_expected.to eql 5432 }
      end
    end

    context 'development' do
      let(:environment) { :development }
      let(:adapter) { 'mysql2' }
      before { hide_const('PG') }
      it { is_expected.to include 'volumes' }
      describe 'local port' do
        subject(:port) { definition['ports'].first.partition(':').first.to_i }
        it { is_expected.to be_positive } # Randomly generated
      end

      describe 'remote port' do
        subject(:port) { definition['ports'].first.partition(':').last.to_i }
        it { is_expected.to eql 3306 }
      end
    end
  end
end
