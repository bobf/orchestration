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
    before { allow(Orchestration).to receive(:random_local_port) { 12_345 } }

    context 'postgresql' do
      let(:adapter) { 'postgresql' }
      let(:environment) { :production }
      before { hide_const('Mysql2') }

      it { is_expected.to be_a Hash }
      its(['image']) { is_expected.to eql 'library/postgres' }
      its(['volumes']) { is_expected.to eql ['dummy_database:/var/pgdata'] }
      its(['environment']) do
        is_expected.to eql(
          'POSTGRES_PASSWORD' => 'password',
          'PGDATA' => '/var/pgdata'
        )
      end

      context 'test environment' do
        let(:environment) { :test }

        its(['networks']) { is_expected.to eql({ 'local' => { 'aliases' => ['database'] } }) }
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
      its(['ports']) { is_expected.to eql ['${sidecar-12345:}5432'] }
    end

    context 'development' do
      let(:environment) { :development }
      let(:adapter) { 'mysql2' }
      before { hide_const('PG') }
      it { is_expected.to include 'volumes' }
      its(['ports']) { is_expected.to eql ['12345:3306'] }
    end
  end
end
