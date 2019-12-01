# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::InstallGenerator do
  subject(:install_generator) { described_class.new(environment, terminal) }

  let(:environment) do
    instance_double(
      Orchestration::Environment,
      docker_api_version: nil,
      database_configuration_path: dummy_path.join('config', 'database.yml'),
      mongoid_configuration_path: dummy_path.join('config', 'mongoid.yml'),
      rabbitmq_configuration_path: dummy_path.join('config', 'rabbitmq.yml'),
      docker_compose_path: docker_compose_path,
      environment: 'test',
      database_url: nil,
      database_volume: 'db_volume',
      mongo_volume: 'mongo_volume',
      public_volume: 'public_volume',
      docker_compose_config?: false
    )
  end

  let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
  let(:orchestration_path) { dummy_path.join('orchestration') }
  let(:docker_compose_path) { orchestration_path.join('docker-compose.yml') }
  let(:terminal) { instance_double(Orchestration::Terminal) }

  before { allow(terminal).to receive(:write) }

  describe '#docker_compose' do
    subject(:docker_compose_yml) { install_generator.docker_compose_yml }

    let(:docker_compose_path) do
      dummy_path.join('orchestration', 'docker-compose.yml')
    end

    before { FileUtils.rm_f(docker_compose_path) }

    it 'creates a docker-compose.yml when not present' do
      docker_compose_yml
      expect(File.exist?(docker_compose_path)).to be true
    end

    describe '#enabled_services' do
      subject(:enabled_services) { install_generator.enabled_services(env) }

      context 'test' do
        let(:env) { :test }
        it { is_expected.to eql %i[database mongo rabbitmq] }
      end

      context 'production' do
        let(:env) { :production }
        it do
          is_expected.to eql %i[application nginx_proxy database mongo rabbitmq]
        end
      end
    end

    describe 'compose file creation' do
      let(:path) { orchestration_path.join("docker-compose.#{env}.yml") }

      before do
        FileUtils.rm_f(path)
        allow(terminal).to receive(:write)
        allow(environment)
          .to receive(:docker_compose_path).with(env) { path }
      end

      after { FileUtils.rm_f(path) }

      context 'production' do
        let(:env) { :production }

        before { install_generator.docker_compose_production_yml }

        it 'creates docker-compose.production.yml' do
          expect(File).to exist(path)
        end

        it 'includes database service' do
          config = YAML.safe_load(File.read(path))
          expect(
            config['services']['database']['image']
          ).to eql 'library/postgres'
        end

        it 'includes mongo service' do
          config = YAML.safe_load(File.read(path))
          expect(
            config['services']['mongo']['image']
          ).to eql 'library/mongo'
        end

        it 'includes rabbitmq service' do
          config = YAML.safe_load(File.read(path))
          expect(
            config['services']['rabbitmq']['image']
          ).to eql 'library/rabbitmq'
        end

        it 'includes application service' do
          config = YAML.safe_load(File.read(path))
          expect(
            config['services']['application']['image']
          ).to eql '${DOCKER_USERNAME}/${DOCKER_REPOSITORY}'
        end
      end

      context 'test' do
        let(:env) { :test }

        before { install_generator.docker_compose_test_yml }

        it 'creates docker-compose.test.yml' do
          expect(File).to exist(path)
        end

        it 'includes database service' do
          config = YAML.safe_load(File.read(path))
          expect(
            config['services']['database']['image']
          ).to eql 'library/postgres'
        end

        it 'includes mongo service' do
          config = YAML.safe_load(File.read(path))
          expect(
            config['services']['mongo']['image']
          ).to eql 'library/mongo'
        end

        it 'includes rabbitmq service' do
          config = YAML.safe_load(File.read(path))
          expect(
            config['services']['rabbitmq']['image']
          ).to eql 'library/rabbitmq'
        end
      end

      context 'override' do
        let(:env) { :override }

        it 'creates docker-compose.override.yml' do
          install_generator.docker_compose_override_yml
          expect(File).to exist(path)
        end
      end
    end

    it 'does not replace an existing docker-compose.yml' do
      File.write(docker_compose_path, 'some docker compose commands')
      docker_compose_yml
      content = File.read(docker_compose_path)
      expect(content).to eql 'some docker compose commands'
    end
  end
end
