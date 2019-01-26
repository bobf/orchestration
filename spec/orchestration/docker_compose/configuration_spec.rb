# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::Configuration do
  subject(:configuration) { described_class.new(env, :test, init_options) }

  let(:env) do
    instance_double(
      Orchestration::Environment,
      docker_api_version: '3.7'
    )
  end

  let(:init_options) { {} }

  it { is_expected.to be_a described_class }

  its(:services) { is_expected.to eql({}) }
  its(:version) { is_expected.to eql('3.7') }

  describe '#volumes' do
    subject { configuration.volumes }

    context 'with database' do
      let(:init_options) { { database: database_configuration } }
      let(:database_configuration) do
        instance_double(
          Orchestration::Services::Database::Configuration,
          env: env,
          settings: { 'port' => 1234 },
          adapter: double(name: nil, image: nil, data_dir: nil, environment: {})
        )
      end

      before { allow(env).to receive(:database_volume) { 'myapp_database' } }

      it { is_expected.to include('myapp_database' => {}) }
    end
  end
end
