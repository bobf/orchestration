# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  let(:install_generator) { described_class.new }

  describe '#makefile' do
    subject(:makefile) { install_generator.makefile }

    let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
    let(:makefile_path) { dummy_path.join('orchestration', 'Makefile') }
    let(:host_makefile_path) { dummy_path.join('Makefile') }

    before do
      FileUtils.rm_f(makefile_path)
      FileUtils.rm_f(host_makefile_path)
    end

    it 'creates a Makefile when not present' do
      makefile
      expect(File.exist?(makefile_path)).to be true
    end

    it 'creates a Makefile with expected content' do
      makefile
      content = File.read(makefile_path)
      expect(content).to include '.PHONY: start stop migrate'
    end

    it 'includes correct wait commands' do
      makefile
      content = File.read(makefile_path)
      expect(content).to include %w[
        wait-database
        wait-mongo
        wait-rabbitmq
        wait-nginx_proxy
        wait-app
      ].join(' ')
    end

    it 'creates makefile in application directory if not present' do
      makefile
      expect(File).to exist(host_makefile_path)
    end

    it 'injects `include` to host Makefile if not present' do
      makefile
      expect(
        File.readlines(host_makefile_path).map(&:chomp)
      ).to include 'include orchestration/Makefile'
    end

    it 'does not inject `include` to host Makefile if already present' do
      File.write(host_makefile_path, 'include orchestration/Makefile')
      makefile
      filter = proc { |line| line == 'include orchestration/Makefile' }
      expect(
        File.readlines(host_makefile_path).map(&:chomp).select(&filter).size
      ).to eql 1
    end

    it 'injects `include` to existing host Makefile if not present' do
      File.write(host_makefile_path, 'some make commands')
      makefile
      filter = proc { |line| line == 'include orchestration/Makefile' }
      expect(
        File.readlines(host_makefile_path).map(&:chomp).select(&filter).size
      ).to eql 1
    end

    it 'retains existing host Makefile content' do
      File.write(host_makefile_path, 'some make commands')
      makefile
      expect(
        File.readlines(host_makefile_path).map(&:chomp)
      ).to include 'some make commands'
    end
  end
end
