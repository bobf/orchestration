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
      root: dummy_path,
      environment: 'test',
      database_url: nil,
      database_volume: 'db_volume',
      mongo_volume: 'mongo_volume',
      docker_compose_config?: false
    )
  end

  let(:dummy_path) { Orchestration.root.join('spec', 'dummy') }
  let(:orchestration_path) { dummy_path.join('orchestration') }
  let(:docker_compose_path) { orchestration_path.join('docker-compose.yml') }
  let(:terminal) { instance_double(Orchestration::Terminal) }

  before { allow(terminal).to receive(:write) }

  describe '#docker_compose_test_yml' do
    subject(:docker_compose_yml) { install_generator.docker_compose_test_yml }

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
          is_expected.to eql %i[app database mongo rabbitmq]
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
          ).to eql 'library/rabbitmq:management'
        end

        it 'includes app service' do
          config = YAML.safe_load(File.read(path))
          expect(
            config['services']['app']['image']
          ).to eql '${DOCKER_ORGANIZATION}/${DOCKER_REPOSITORY}:${DOCKER_TAG}'
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
          ).to eql 'library/rabbitmq:management'
        end
      end

      context 'development' do
        let(:env) { :development }

        before { install_generator.docker_compose_development_yml }

        it 'creates docker-compose.development.yml' do
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
          ).to eql 'library/rabbitmq:management'
        end
      end
    end
  end
end
