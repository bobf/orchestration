# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  subject(:install_generator) { described_class.new }

  it { is_expected.to be_a described_class }

  let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
  let(:yaml_bash_path) { dummy_path.join('orchestration', 'yaml.bash') }
  let(:nginx_tmpl_path) { dummy_path.join('orchestration', 'nginx.tmpl') }

  before do
    FileUtils.rm_f(yaml_bash_path)
    FileUtils.rm_f(nginx_tmpl_path)
  end

  it 'creates yaml.bash' do
    install_generator.yaml_bash
    expect(File).to exist(yaml_bash_path)
  end
end
