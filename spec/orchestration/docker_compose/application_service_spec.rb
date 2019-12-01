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
    its(['image']) { is_expected.to eql 'dockeruser/test_app' }
    its(%w[environment SECRET_KEY_BASE]) { is_expected.to be_nil }
    its(%w[environment RAILS_LOG_TO_STDOUT]) { is_expected.to eql '1' }
    its(%w[environment DATABASE_URL]) do
      is_expected.to eql 'postgres://postgres:password@database:3354/postgres'
    end
  end
end
