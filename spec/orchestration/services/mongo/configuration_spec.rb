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
            'database' => 'test_db', 'hosts' => ['127.0.0.1:27020']
          }
        }
      }
    end

    it { is_expected.to eql(expected_settings) }

    context 'MONGO_URL' do
      before do
        allow(ENV).to receive(:[]).with('MONGO_URL') { 'mongo:1234/db' }
        allow(ENV).to receive(:key?).with('MONGO_URL') { true }
      end

      subject(:default) { settings['clients']['default'] }
      its(['database']) { is_expected.to eql 'db' }
      its(['hosts']) { is_expected.to eql ['mongo:1234'] }
    end
  end

  its(:friendly_config) do
    is_expected.to eql '[mongoid] 127.0.0.1:27020/test_db'
  end
end
