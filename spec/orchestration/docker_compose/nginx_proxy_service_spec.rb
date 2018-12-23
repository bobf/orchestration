# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::NginxProxyService do
  subject(:nginx_proxy_service) { described_class.new(configuration, :test) }

  let(:env) do
    instance_double(
      Orchestration::Environment,
      environment: 'test',
      orchestration_root: Pathname.new('orchestration'),
      public_volume: 'myapp_public'
    )
  end

  let(:configuration) do
    Orchestration::Services::NginxProxy::Configuration.new(env)
  end

  it { is_expected.to be_a described_class }

  describe '#definition' do
    subject(:definition) { nginx_proxy_service.definition }

    its(['image']) { is_expected.to eql 'rubyorchestration/nginx-proxy' }
    its(['ports']) { is_expected.to eql ['${LISTEN_PORT}:80'] }
    its(['volumes']) do
      is_expected.to eql [
        '/var/run/docker.sock:/tmp/docker.sock:ro',
        'myapp_public:/var/www/public/:ro'
      ]
    end
  end
end
