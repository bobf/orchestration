# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  let(:install_generator) { described_class.new }

  describe '#gitignore' do
    subject(:gitignore) { install_generator.gitignore }

    let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
    let(:gitignore_path) { dummy_path.join('.gitignore') }

    before { FileUtils.rm_f(gitignore_path) }

    it 'creates a .gitignore when not present' do
      gitignore
      expect(File.exist?(gitignore_path)).to be true
    end

    it 'retains content of existing .gitignore' do
      File.write(gitignore_path, '/an/ignored/path')
      gitignore
      content = File.read(gitignore_path)
      expect(content).to include '/an/ignored/path'
    end

    it 'appends to existing .gitignore' do
      File.write(gitignore_path, '/an/ignored/path')
      gitignore
      content = File.read(gitignore_path)
      expect(content).to include "\ndocker/.build\n"
    end

    it 'does not add content more than once' do
      gitignore
      size = File.size(gitignore_path)
      gitignore
      gitignore
      gitignore
      gitignore
      expect(size).to eql File.size(gitignore_path)
    end

    shared_examples 'a .gitignore entry' do |entry|
      it 'writes entry to .gitignore' do
        gitignore
        expect(File.read(gitignore_path)).to include entry
      end
    end

    [
      'docker/.build',
      'docker/Gemfile',
      'docker/Gemfile.lock',
      'docker/*.gemspec'
    ].each do |entry|
      it_behaves_like 'a .gitignore entry', entry
    end
  end
end
