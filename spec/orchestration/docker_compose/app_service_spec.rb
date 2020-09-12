# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::AppService do
  subject(:app_service) { described_class.new(configuration, :test) }

  let(:configuration) do
    Orchestration::Services::App::Configuration.new(env)
  end

  let(:env) do
    instance_double(
      Orchestration::Environment,
      environment: 'test',
      orchestration_root: Pathname.new('orchestration'),
      app_name: 'test_app',
      database_url: 'postgresql://hostname',
      settings: settings,
      docker_compose_config?: false,
      database_configuration_path: fixture_path('postgresql')
    )
  end

  let(:settings) { double('Settings') }

  describe '#definition' do
    subject(:definition) { app_service.definition }

    it { is_expected.to be_a Hash }
    its(['image']) do
      is_expected
        .to eql '${DOCKER_ORGANIZATION}/${DOCKER_REPOSITORY}:${DOCKER_TAG}'
    end

    its(['environment']) { is_expected.to include 'HOST_UID' }
    its(['environment']) { is_expected.to include 'RAILS_ENV' }
    its(['environment']) { is_expected.to include 'SECRET_KEY_BASE' }
    its(['environment']) { is_expected.to include 'DATABASE_URL' }
    its(['environment']) { is_expected.to include 'WEB_PRELOAD_APP' }
    its(['environment']) { is_expected.to include 'WEB_TIMEOUT' }
    its(['environment']) { is_expected.to include 'WEB_CONCURRENCY' }
    its(['environment']) { is_expected.to include 'WEB_WORKER_PROCESSES' }
    its(%w[environment RAILS_LOG_TO_STDOUT]) { is_expected.to eql '1' }

    context 'PG gem present' do
      before do
        stub_const('PG', nil)
        hide_const('Mysql2')
        hide_const('SQLite3')
      end

      its(%w[environment DATABASE_URL]) do
        is_expected.to eql 'postgresql://postgres:password@database-local:5432/production'
      end
    end

    context 'Mysql2 gem present' do
      before do
        stub_const('Mysql2', nil)
        hide_const('PG')
        hide_const('SQLite3')
      end

      its(%w[environment DATABASE_URL]) do
        is_expected.to eql 'mysql2://root:password@database-local:3306/production'
      end
    end

    context 'SQLite3 gem present' do
      before do
        stub_const('SQLite3', nil)
        hide_const('PG')
        hide_const('Mysql2')
      end

      its(%w[environment DATABASE_URL]) do
        is_expected.to eql 'sqlite3:db/production.sqlite3'
      end
    end

    its(['ports']) do
      is_expected.to eql [
        '${PUBLISH_PORT:?PUBLISH_PORT must be provided}:8080'
      ]
    end
  end
end
