# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  let(:install_generator) { described_class.new }

  describe '#makefile' do
    subject(:makefile) { install_generator.makefile }

    let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
    let(:makefile_path) { dummy_path.join('Makefile') }

    before { FileUtils.rm_f(makefile_path) }

    it 'creates a Makefile when not present' do
      makefile
      expect(File.exist?(makefile_path)).to be true
    end

    it 'appends to an existing Makefile' do
      File.write(makefile_path, 'some make commands')
      makefile
      content = File.read(makefile_path)
      expect(content).to include 'some make commands'
    end

    it 'includes new content when appending' do
      File.write(makefile_path, 'some make commands')
      makefile
      content = File.read(makefile_path)
      expect(content).to include '.PHONY: start stop migrate'
    end

    it 'replaces previous Orchestration-specific content' do
      File.write(makefile_path, 'some make commands')
      makefile
      size = File.size(makefile_path)
      makefile
      makefile
      makefile
      expect(File.size(makefile_path)).to eql size
    end
  end
end
