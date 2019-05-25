# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::RabbitMQService do
  subject(:rabbitmq_service) { described_class.new(config, environment) }

  let(:config) { double('Configuration', settings: settings, enabled?: true) }
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
      describe 'local port' do
        subject(:port) { definition['ports'].first.partition(':').first.to_i }
        it { is_expected.to be_positive } # Randomly generated
      end

      describe 'remote port' do
        subject(:port) { definition['ports'].first.partition(':').last.to_i }
        it { is_expected.to eql 5672 }
      end
    end

    context 'development' do
      let(:environment) { :development }
      describe 'local port' do
        subject(:port) { definition['ports'].first.partition(':').first.to_i }
        it { is_expected.to be_positive } # Randomly generated
      end

      describe 'remote port' do
        subject(:port) { definition['ports'].first.partition(':').last.to_i }
        it { is_expected.to eql 5672 }
      end
    end

    context 'production' do
      let(:environment) { :production }
      it { is_expected.to_not include 'ports' }
    end

    context 'test' do
      let(:environment) { :test }
      describe 'local port' do
        subject(:port) { definition['ports'].first.partition(':').first.to_i }
        it { is_expected.to be_positive } # Randomly generated
      end

      describe 'remote port' do
        subject(:port) { definition['ports'].first.partition(':').last.to_i }
        it { is_expected.to eql 5672 }
      end
    end

    context 'development' do
      let(:environment) { :development }
      describe 'local port' do
        subject(:port) { definition['ports'].first.partition(':').first.to_i }
        it { is_expected.to be_positive } # Randomly generated
      end

      describe 'remote port' do
        subject(:port) { definition['ports'].first.partition(':').last.to_i }
        it { is_expected.to eql 5672 }
      end
    end
  end
end
