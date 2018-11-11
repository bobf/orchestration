# frozen_string_literal: true

RSpec.describe Orchestration::InstallGenerator do
  let(:install_generator) { described_class.new }

  describe '#docker_compose' do
    subject(:docker_compose) { install_generator.docker_compose }

    let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
    let(:docker_compose_path) { dummy_path.join('docker-compose.yml') }

    before { FileUtils.rm_f(docker_compose_path) }

    it 'creates a docker-compose.yml when not present' do
      docker_compose
      expect(File.exist?(docker_compose_path)).to be true
    end

    it 'does not replace an existing docker-compose.yml' do
      File.write(docker_compose_path, 'version: "3.7"')
      docker_compose
      content = File.read(docker_compose_path)
      expect(content).to include 'version: "3.7"'
    end

    it 'includes database service' do
      docker_compose
      config = YAML.safe_load(File.read(docker_compose_path))
      expect(config['services']['database']['image']).to eql 'library/postgres'
    end
  end
end
