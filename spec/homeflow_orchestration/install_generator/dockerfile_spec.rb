# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  let(:install_generator) { described_class.new }

  describe '#dockerfile' do
    subject(:dockerfile) { install_generator.dockerfile }

    let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
    let(:dockerfile_path) { dummy_path.join('docker', 'Dockerfile') }

    before { FileUtils.rm_f(dockerfile_path) }

    it 'creates a Dockerfile when not present' do
      dockerfile
      expect(File.exist?(dockerfile_path)).to be true
    end

    it 'does not replace existing Dockerfile' do
      File.write(dockerfile_path, 'some docker commands')
      dockerfile
      content = File.read(dockerfile_path)
      expect(content).to eql 'some docker commands'
    end

    it 'uses appropriate Ruby image' do
      dockerfile
      content = File.read(dockerfile_path)
      expect(content).to include "ruby:#{RUBY_VERSION}"
    end
  end
end
