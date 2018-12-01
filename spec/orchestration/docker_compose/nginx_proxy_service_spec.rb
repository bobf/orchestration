# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::NginxProxyService do
  subject(:nginx_proxy_service) { described_class.new(configuration) }

  let(:env) do
    double(
      'Environment',
      environment: 'test'
    )
  end

  let(:configuration) do
    Orchestration::Services::NginxProxy::Configuration.new(env)
  end

  it { is_expected.to be_a described_class }

  describe '#definition' do
    subject(:definition) { nginx_proxy_service.definition }

    its(['image']) { is_expected.to eql 'jwilder/nginx-proxy' }
    its(['volumes']) do
      is_expected.to eql ['/var/run/docker.sock:/tmp/docker.sock:ro']
    end
  end
end
