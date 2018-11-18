# frozen_string_literal: true

RSpec.shared_examples 'a service' do |service|
  describe 'healthcheck class' do
    subject(:healthcheck) { service::Healthcheck }
    it { is_expected.to respond_to :start }
  end

  describe 'healthcheck instance' do
    subject(:healthcheck) { service::Healthcheck.new(env) }

    let(:env) do
      double(
        'Environment',
        environment: 'test',
        database_url: nil,
        database_configuration_path: fixture_path('sqlite3'),
        mongoid_configuration_path: fixture_path('mongoid'),
        rabbitmq_configuration_path: fixture_path('rabbitmq')
      )
    end

    it { is_expected.to respond_to :connect }
    its(:connection_errors) { is_expected.to be_an Array }
    its(:connection_errors) { is_expected.to_not be_empty }

    describe '#configuration' do
      subject(:configuration) { healthcheck.configuration }

      it { is_expected.to respond_to :settings }
    end
  end
end
