# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::Services do
  subject(:services) { described_class.new(env, init_options) }

  let(:env) do
    instance_double(
      Orchestration::Environment,
      public_volume: 'myapp_public',
      docker_api_version: '3.7'
    )
  end
  let(:init_options) { {} }

  it { is_expected.to be_a described_class }

  its(:structure) do
    is_expected.to eql(
      'version' => '3.7',
      'services' => {},
      'volumes' => { 'myapp_public' => {} }
    )
  end

  describe '#structure["volumes"]' do
    subject { services.structure.fetch('volumes') }

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
