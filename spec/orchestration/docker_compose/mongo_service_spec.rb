# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::MongoService do
  subject(:mongo_service) { described_class.new(configuration, environment) }

  let(:config) { fixture_path('mongoid') }
  let(:environment) { :test }
  let(:env) do
    double(
      'Environment',
      environment: 'test',
      mongoid_configuration_path: config,
      mongo_volume: 'mongo_data_volume'
    )
  end

  let(:configuration) do
    Orchestration::Services::Mongo::Configuration.new(env)
  end

  it { is_expected.to be_a described_class }

  describe '#definition' do
    subject(:definition) { mongo_service.definition }

    its(['image']) { is_expected.to eql 'library/mongo' }

    describe 'local port' do
      subject(:port) { definition['ports'].first.partition(':').first.to_i }
      it { is_expected.to be_positive } # Randomly generated
    end

    describe 'remote port' do
      subject(:port) { definition['ports'].first.partition(':').last.to_i }
      it { is_expected.to eql 27_017 }
    end

    context 'mongoid not configured' do
      before { hide_const('Mongoid') }
      it { is_expected.to be_nil }
    end

    context 'production' do
      let(:environment) { :production }
      its(['volumes']) { is_expected.to eql ['mongo_data_volume:/data/db'] }
      it { is_expected.to_not include 'ports' }
    end

    context 'test' do
      let(:environment) { :test }
      it { is_expected.to_not include 'volumes' }
      describe 'local port' do
        subject(:port) { definition['ports'].first.partition(':').first.to_i }
        it { is_expected.to be_positive } # Randomly generated
      end

      describe 'remote port' do
        subject(:port) { definition['ports'].first.partition(':').last.to_i }
        it { is_expected.to eql 27_017 }
      end
    end

    context 'development' do
      let(:environment) { :development }
      its(['volumes']) { is_expected.to eql ['mongo_data_volume:/data/db'] }
      describe 'local port' do
        subject(:port) { definition['ports'].first.partition(':').first.to_i }
        it { is_expected.to be_positive } # Randomly generated
      end

      describe 'remote port' do
        subject(:port) { definition['ports'].first.partition(':').last.to_i }
        it { is_expected.to eql 27_017 }
      end
    end
  end
end
