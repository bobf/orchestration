# frozen_string_literal: true

RSpec.describe Orchestration::Kubernetes::InstallGenerator do
  subject(:install_generator) { described_class.new(environment, terminal) }

  let(:environment) do
    instance_double(
      Orchestration::Environment,
      root: dummy_path,
      kubernetes_configuration_path: dummy_path.join('orchestration', 'kubernetes'),
      app_name: 'example',
      organization: 'acme'
    )
  end

  let(:terminal) { instance_double(Orchestration::Terminal) }

  let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
  let(:kubernetes_path) { dummy_path.join('orchestration', 'kubernetes') }
  let(:deployment_path) { kubernetes_path.join('deployment.yml') }
  let(:service_path) { kubernetes_path.join('service.yml') }
  let(:kustomize_path) { kubernetes_path.join('kustomization.yml') }

  before { allow(terminal).to receive(:write) }
  before { install_generator.kubernetes }
  after { kubernetes_config_path.rmtree }

  let(:kubernetes_config_path) { dummy_path.join('orchestration', 'kubernetes') }

  describe 'deployment.yml' do
    subject(:deployment) { YAML.safe_load(deployment_path.read, symbolize_names: true) }

    it { is_expected.to be_a Hash }

    its([:apiVersion]) { is_expected.to eql 'apps/v1' }
    its([:kind]) { is_expected.to eql 'Deployment' }
    its([:metadata]) { is_expected.to eql({ name: 'example' }) }

    describe '[:spec]' do
      subject(:spec) { deployment[:spec] }

      its([:replicas]) { is_expected.to eql 3 }
      its([:selector]) { is_expected.to eql({ matchLabels: { app: 'example' } }) }

      describe '[:template]' do
        subject(:template) { spec[:template] }

        its([:metadata]) { is_expected.to eql({ labels: { app: 'example' } }) }

        describe '[:spec][:containers]' do
          subject(:containers) { template[:spec][:containers].first }
          its([:name]) { is_expected.to eql 'example' }
          its([:image]) { is_expected.to eql 'acme/example' }
          its([:ports]) { is_expected.to eql [{ containerPort: 8080 }] }
        end
      end
    end
  end

  describe 'service.yml' do
    subject(:service) { YAML.safe_load(service_path.read, symbolize_names: true) }

    it { is_expected.to be_a Hash }

    its([:apiVersion]) { is_expected.to eql 'v1' }
    its([:kind]) { is_expected.to eql 'Service' }
    its([:metadata]) { is_expected.to eql({ name: 'example', labels: { run: 'example' } }) }

    describe '[:spec]' do
      subject(:spec) { service[:spec] }

      its([:selector]) { is_expected.to eql({ run: 'example' }) }
      its([:type]) { is_expected.to eql 'LoadBalancer' }
      its([:ports]) do
        is_expected.to eql [{ port: 8080, targetPort: 8080, protocol: 'TCP', name: 'http' }]
      end
    end
  end

  describe 'kustomize.yml' do
    subject(:kustomize) { YAML.safe_load(kustomize_path.read, symbolize_names: true) }

    it { is_expected.to be_a Hash }
    its([:apiVersion]) { is_expected.to eql 'kustomize.config.k8s.io/v1beta1' }
    its([:kind]) { is_expected.to eql 'Kustomization' }
    its([:resources]) { is_expected.to eql %w[deployment.yml service.yml] }
    its([:patchesStrategicMerge]) { is_expected.to eql %w[environmentPatch.yml] }
  end
end
