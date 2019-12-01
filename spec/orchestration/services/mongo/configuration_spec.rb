# frozen_string_literal: true

RSpec.describe Orchestration::Services::Mongo::Configuration do
  subject(:configuration) { described_class.new(env) }

  let(:config) { fixture_path('mongoid') }
  let(:env) do
    double(
      'Environment',
      environment: 'test',
      mongoid_configuration_path: config,
      docker_compose_config: {
        'services' => { 'mongo' => { 'ports' => ['27018:27017'] } }
      }
    )
  end

  it { is_expected.to be_a described_class }

  describe '#settings' do
    subject(:settings) { configuration.settings }

    let(:expected_settings) do
      {
        'clients' => {
          'default' => {
            'database' => 'test_db', 'hosts' => ['localhost:27020']
          }
        }
      }
    end

    it { is_expected.to eql(expected_settings) }
  end

  its(:friendly_config) { is_expected.to eql '[mongoid] localhost:27018' }
end
