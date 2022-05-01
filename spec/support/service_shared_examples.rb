# frozen_string_literal: true

RSpec.shared_examples 'a service' do |service|
  describe 'healthcheck class' do
    subject(:healthcheck) { service::Healthcheck }
    it { is_expected.to respond_to :start }
  end

  describe 'healthcheck instance' do
    subject(:healthcheck) { service::Healthcheck.new(env, 'myservice') }

    let(:environment) { 'test' }
    let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }

    let(:env) do
      double(
        'Environment',
        environment:,
        database_configuration_path: '/non/existent/path/i/hope',
        database_url: 'postgresql://',
        mongo_url: nil,
        docker_compose_config: {
          'services' => { 'myservice' => { 'ports' => ['1234:5678'] } }
        }
      )
    end

    it { is_expected.to respond_to :connect }
    its(:connection_errors) { is_expected.to be_an Array }
    its(:connection_errors) { is_expected.to_not be_empty }

    describe '#configuration' do
      subject(:configuration) { healthcheck.configuration }

      context 'test environment' do
        let(:environment) { 'test' }
        its(:port) { is_expected.to eql 1234 }
        its(:host) { is_expected.to eql '127.0.0.1' }
      end

      context 'development environment' do
        let(:environment) { 'development' }
        its(:port) { is_expected.to eql 1234 }
        its(:host) { is_expected.to eql '127.0.0.1' }
      end
    end
  end
end
