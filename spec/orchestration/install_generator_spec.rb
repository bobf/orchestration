# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  subject(:install_generator) { described_class.new }

  it { is_expected.to be_a described_class }

  let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
  let(:orchestration_path) { dummy_path.join('orchestration') }
  let(:yaml_bash_path) { orchestration_path.join('yaml.bash') }

  before { FileUtils.rm_f(yaml_bash_path) }

  it 'creates yaml.bash' do
    install_generator.yaml_bash
    expect(File).to exist(yaml_bash_path)
  end
end
