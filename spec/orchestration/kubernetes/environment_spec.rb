# frozen_string_literal: true

RSpec.describe Orchestration::Kubernetes::Environment do
  subject(:environment) { described_class.new(env_file: env_file) }

  let(:env_file) { fixture('example.env').path }

  it { is_expected.to be_a described_class }
  its(:content) { is_expected.to be_a String }

  describe '#content' do
    subject(:content) { YAML.safe_load(environment.content) }

    it { is_expected.to be_a Hash }
    its(['apiVersion']) { is_expected.to eql 'apps/v1' }
    its(['kind']) { is_expected.to eql 'Deployment' }
    its(%w[metadata name]) { is_expected.to eql 'dummy' }
    its(['spec', 'template', 'spec', 'containers', 0, 'name']) { is_expected.to eql 'dummy' }

    describe '["spec"]["template"]["containers"][0]["env"]' do
      subject(:env) do
        YAML.safe_load(environment.content)['spec']['template']['spec']['containers'][0]['env']
      end

      it { is_expected.to be_an Array }
      it { is_expected.to include({ 'name' => 'FOO', 'value' => 'foo value' }) }
      # Quotes should be interpreted as literal characters - https://docs.docker.com/compose/env-file/
      it { is_expected.to include({ 'name' => 'BAR', 'value' => '"bar value"' }) }
      it { is_expected.to include({ 'name' => 'BAZ', 'value' => "'baz value'" }) }
    end
  end

  context 'no env file present' do
    subject(:content) { YAML.safe_load(described_class.new(env_file: nil).content) }
    its(['spec', 'template', 'spec', 'containers', 0, 'env']) { is_expected.to eql [] }
  end
end
