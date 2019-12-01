# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::RabbitMQService do
  subject(:rabbitmq_service) { described_class.new(config, environment) }

  let(:config) { double('Configuration', settings: settings) }
  let(:settings) { { 'port' => 5674 } }
  let(:environment) { :test }

  it { is_expected.to be_a described_class }

  describe '#definition' do
    subject(:definition) { rabbitmq_service.definition }

    its(['image']) { is_expected.to eql('library/rabbitmq') }

    context 'production' do
      let(:environment) { :production }
      it { is_expected.to_not include 'ports' }
    end

    context 'test' do
      let(:environment) { :test }
      its(['ports']) { is_expected.to eql(['5674:5672']) }
    end

    context 'development' do
      let(:environment) { :development }
      its(['ports']) { is_expected.to eql(['5674:5672']) }
    end

    context 'production' do
      let(:environment) { :production }
      it { is_expected.to_not include 'ports' }
    end

    context 'test' do
      let(:environment) { :test }
      its(['ports']) { is_expected.to eql(['5674:5672']) }
    end

    context 'development' do
      let(:environment) { :development }
      its(['ports']) { is_expected.to eql(['5674:5672']) }
    end
  end
end
