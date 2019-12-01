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
      public_volume: 'myapp_public',
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
      is_expected.to eql '${DOCKER_ORGANIZATION}/${DOCKER_REPOSITORY}'
    end

    its(['environment']) { is_expected.to have_key 'HOST_UID' }
    its(['environment']) { is_expected.to have_key 'RAILS_ENV' }
    its(['environment']) { is_expected.to have_key 'SECRET_KEY_BASE' }
    its(['environment']) { is_expected.to have_key 'DATABASE_URL' }
    its(%w[environment RAILS_LOG_TO_STDOUT]) { is_expected.to eql '1' }
    its(%w[environment UNICORN_PRELOAD_APP]) { is_expected.to eql '1' }
    its(%w[environment UNICORN_TIMEOUT]) { is_expected.to eql '60' }
    its(%w[environment UNICORN_WORKER_PROCESSES]) { is_expected.to eql '8' }
    its(%w[environment SERVICE_PORTS]) { is_expected.to eql '8080' }
  end
end
