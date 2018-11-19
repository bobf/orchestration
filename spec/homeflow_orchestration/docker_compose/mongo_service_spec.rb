# frozen_string_literal: true

RSpec.describe HomeflowOrchestration::DockerCompose::MongoService do
  subject(:mongo_service) { described_class.new(configuration) }

  let(:config) { fixture_path('mongoid') }
  let(:env) do
    double(
      'Environment',
      environment: 'test',
      mongoid_configuration_path: config
    )
  end

  let(:configuration) do
    HomeflowOrchestration::Services::Mongo::Configuration.new(env)
  end

  it { is_expected.to be_a described_class }

  describe '#definition' do
    subject(:definition) { mongo_service.definition }

    its(['image']) { is_expected.to eql 'library/mongo' }
    its(['ports']) { is_expected.to eql ['27017:27017'] }

    context 'multiple hosts' do
      let(:config) { fixture_path('mongoid_multiple_hosts') }
      its(['ports']) { is_expected.to eql ['27017:27017', '27018:27017'] }
    end

    context 'mongoid not configured' do
      let(:config) { '/path/to/non/existent/mongoid.yml' }

      it { is_expected.to be_nil }
    end
  end
end
