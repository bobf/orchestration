# frozen_string_literal: true

RSpec.describe Orchestration::Kubernetes::Image do
  subject(:environment) { described_class.new(image: 'myorg/myapp:mytag') }

  it { is_expected.to be_a described_class }
  its(:content) { is_expected.to be_a String }

  describe '#content' do
    subject(:content) { YAML.safe_load(environment.content) }

    it { is_expected.to be_a Hash }
    its(['apiVersion']) { is_expected.to eql 'apps/v1' }
    its(['kind']) { is_expected.to eql 'Deployment' }
    its(%w[metadata name]) { is_expected.to eql 'dummy' }
    its(['spec', 'template', 'spec', 'containers', 0, 'image']) { is_expected.to eql 'myorg/myapp:mytag' }
  end
end
