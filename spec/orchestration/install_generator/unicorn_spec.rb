# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  before { allow(ENV).to receive(:fetch).with('server', 'puma') { 'unicorn' } }
  let(:install_generator) { described_class.new }

  describe '#unicorn' do
    subject(:unicorn) { install_generator.unicorn }

    let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
    let(:unicorn_path) { dummy_path.join('config', 'unicorn.rb') }

    before { FileUtils.rm_f(unicorn_path) }
    before { FileUtils.rm_f("#{unicorn_path}.bak") }

    it 'creates unicorn.rb when not present' do
      unicorn
      expect(File.exist?(unicorn_path)).to be true
    end

    it 'replaces existing unicorn.rb' do
      File.write(unicorn_path, 'some unicorn configuration')
      unicorn
      content = File.read(unicorn_path)
      expect(content).to_not include 'some unicorn configuration'
    end

    it 'backs up existing unicorn.rb' do
      File.write(unicorn_path, 'some unicorn configuration')
      unicorn
      content = File.read("#{unicorn_path}.bak")
      expect(content).to eql 'some unicorn configuration'
    end
  end
end
