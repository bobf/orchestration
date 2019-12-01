# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  let(:install_generator) { described_class.new }

  describe '#entrypoint_sh' do
    subject(:entrypoint_sh) { install_generator.entrypoint_sh }

    let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
    let(:entrypoint_path) { dummy_path.join('orchestration', 'entrypoint.sh') }

    before { FileUtils.rm_f(entrypoint_path) }

    it 'creates entrypoint.sh when not present' do
      entrypoint_sh
      expect(File.exist?(entrypoint_path)).to be true
    end

    it 'sets executable permissions on entrypoint.sh' do
      entrypoint_sh
      expect(File.executable?(entrypoint_path)).to be true
    end

    it 'does not replace existing entrypoint.sh' do
      File.write(entrypoint_path, 'some shell commands')
      entrypoint_sh
      content = File.read(entrypoint_path)
      expect(content).to eql 'some shell commands'
    end
  end
end
