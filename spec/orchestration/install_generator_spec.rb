# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  subject(:install_generator) { described_class.new }

  it { is_expected.to be_a described_class }

  let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
  let(:orchestration_path) { dummy_path.join('orchestration') }
  let(:yaml_bash_path) { orchestration_path.join('yaml.bash') }
  let(:override_path) { orchestration_path.join('docker-compose.override.yml') }

  before do
    FileUtils.rm_f(yaml_bash_path)
    FileUtils.rm_f(override_path)
  end

  it 'creates yaml.bash' do
    install_generator.yaml_bash
    expect(File).to exist(yaml_bash_path)
  end

  it 'creates docker-compose.override.yml' do
    install_generator.docker_compose_override_yml
    expect(File).to exist(override_path)
  end
end
