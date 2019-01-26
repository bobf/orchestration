# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::HAProxyService do
  subject(:haproxy_service) { described_class.new(configuration, :test) }

  let(:env) do
    instance_double(
      Orchestration::Environment,
      environment: 'test',
      orchestration_root: Pathname.new('orchestration'),
      public_volume: 'myapp_public'
    )
  end

  let(:configuration) do
    Orchestration::Services::HAProxy::Configuration.new(env)
  end

  it { is_expected.to be_a described_class }

  describe '#definition' do
    subject(:definition) { haproxy_service.definition }

    its(['image']) { is_expected.to eql 'dockercloud/haproxy' }
    its(['ports']) { is_expected.to eql ['${LISTEN_PORT}:80'] }
    its(['volumes']) do
      is_expected.to eql ['/var/run/docker.sock:/var/run/docker.sock:ro']
    end
  end
end
