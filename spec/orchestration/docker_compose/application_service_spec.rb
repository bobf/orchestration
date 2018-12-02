# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::ApplicationService do
  subject(:application_service) { described_class.new(configuration) }

  let(:configuration) do
    Orchestration::Services::Application::Configuration.new(env)
  end

  let(:env) do
    double(
      'Environment',
      application_name: 'test_app',
      environment: 'test',
      database_url: 'postgres://hostname',
      settings: settings,
      database_configuration_path: fixture_path('postgresql')
    )
  end

  let(:settings) { double('Settings') }

  describe '#definition' do
    subject(:definition) { application_service.definition }

    before do
      allow(settings).to receive(:get).with('docker.username') { 'dockeruser' }
    end

    it { is_expected.to be_a Hash }
    its(['command']) do
      is_expected.to eql %w[
        bundle exec unicorn -c /application/config/unicorn.rb
      ]
    end

    its(['entrypoint']) { is_expected.to eql '/entrypoint.sh' }
    its(['expose']) { is_expected.to eql [8080] }
    its(['image']) { is_expected.to eql 'dockeruser/test_app' }
    its(['environment']) { is_expected.to have_key 'HOST_UID' }
    its(['environment']) { is_expected.to have_key 'RAILS_ENV' }
    its(['environment']) { is_expected.to have_key 'SECRET_KEY_BASE' }
    its(%w[environment RAILS_LOG_TO_STDOUT]) { is_expected.to eql '1' }
    its(%w[environment DATABASE_URL]) do
      is_expected.to eql 'postgres://postgres:password@database:5432/postgres'
    end

    its(%w[environment UNICORN_PRELOAD_APP]) { is_expected.to eql '1' }
    its(%w[environment UNICORN_TIMEOUT]) { is_expected.to eql '60' }
    its(%w[environment UNICORN_WORKER_PROCESSES]) { is_expected.to eql '8' }
    its(%w[environment VIRTUAL_PORT]) { is_expected.to eql '8080' }
    its(%w[environment VIRTUAL_HOST]) { is_expected.to eql 'localhost' }
  end
end
