# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  let(:install_generator) { described_class.new }

  describe '#dockerfile' do
    subject(:entrypoint) { install_generator.entrypoint }

    let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
    let(:entrypoint_path) { dummy_path.join('docker', 'entrypoint.sh') }

    before { FileUtils.rm_f(entrypoint_path) }

    it 'creates entrypoint.sh when not present' do
      entrypoint
      expect(File.exist?(entrypoint_path)).to be true
    end

    it 'sets executable permissions on entrypoint.sh' do
      entrypoint
      expect(File.executable?(entrypoint_path)).to be true
    end

    it 'does not replace existing entrypoint.sh' do
      File.write(entrypoint_path, 'some shell commands')
      entrypoint
      content = File.read(entrypoint_path)
      expect(content).to eql 'some shell commands'
    end
  end
end
