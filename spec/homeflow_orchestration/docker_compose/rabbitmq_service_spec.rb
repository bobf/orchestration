# frozen_string_literal: true

RSpec.describe HomeflowOrchestration::DockerCompose::RabbitMQService do
  subject(:rabbitmq_service) { described_class.new(config) }

  let(:config) { double('Configuration', settings: settings) }
  let(:settings) { { 'port' => 5674 } }

  it { is_expected.to be_a described_class }

  describe '#definition' do
    subject(:definition) { rabbitmq_service.definition }

    its(['image']) { is_expected.to eql('library/rabbitmq') }
    its(['ports']) { is_expected.to eql(['5674:5672']) }
  end
end
