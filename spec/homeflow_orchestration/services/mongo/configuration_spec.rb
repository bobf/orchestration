# frozen_string_literal: true

RSpec.describe HomeflowOrchestration::Services::Mongo::Configuration do
  subject(:configuration) { described_class.new(env) }

  let(:config) { fixture_path('mongoid') }
  let(:env) do
    double(
      'Environment',
      environment: 'test',
      mongoid_configuration_path: config
    )
  end

  it { is_expected.to be_a described_class }

  describe '#settings' do
    subject(:settings) { configuration.settings }

    let(:expected_settings) do
      {
        'clients' => {
          'default' => {
            'database' => 'test_db', 'hosts' => ['localhost']
          }
        }
      }
    end

    it { is_expected.to eql(expected_settings) }
  end

  describe '#friendly_config' do
    subject(:friendly_config) { configuration.friendly_config }

    it { is_expected.to eql '[mongoid] localhost:27017' }

    context 'multiple hosts' do
      let(:config) { fixture_path('mongoid_multiple_hosts') }
      it { is_expected.to eql '[mongoid] localhost:27017, example.com:27018' }
    end
  end
end
