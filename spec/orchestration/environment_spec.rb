# frozen_string_literal: true

RSpec.describe Orchestration::Environment do
  subject(:environment) { described_class.new(options) }

  let(:options) { {} }

  it { is_expected.to be_a described_class }

  describe '#environment' do
    subject { environment.environment }

    it { is_expected.to eql 'test' }

    context 'from environment' do
      before { allow(ENV).to receive(:[]).and_call_original }

      context 'RAILS_ENV' do
        before { allow(ENV).to receive(:[]).with('RAILS_ENV') { 'myenv' } }
        it { is_expected.to eql 'myenv' }
      end

      context 'RACK_ENV' do
        before { allow(ENV).to receive(:[]).with('RAILS_ENV') { 'myenv' } }
        it { is_expected.to eql 'myenv' }
      end
    end

    context 'from initializer' do
      let(:options) { { environment: 'myenv' } }
      it { is_expected.to eql 'myenv' }
    end
  end

  its(:database_configuration_path) { is_expected.to be_a Pathname }
  its(:mongoid_configuration_path) { is_expected.to be_a Pathname }
  its(:rabbitmq_configuration_path) { is_expected.to be_a Pathname }
  its(:docker_compose_path) { is_expected.to be_a Pathname }
  its(:database_volume) { is_expected.to eql 'database' }
  its(:mongo_volume) { is_expected.to eql 'mongo' }

  describe '#database_url' do
    subject(:database_url) { environment.database_url }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DATABASE_URL') { 'database-url' }
    end

    context 'development' do
      before do
        allow(ENV).to receive(:[]).with('RAILS_ENV') { 'development' }
      end

      context 'with DEVELOPMENT_DATABASE_URL set' do
        before do
          allow(ENV).to receive(:[]).with('DEVELOPMENT_DATABASE_URL') { 'abc' }
        end

        it { is_expected.to eql 'abc' }
      end

      context 'without DEVELOPMENT_DATABASE_URL set' do
        it { is_expected.to eql 'database-url' }
      end
    end

    context 'test' do
      before do
        allow(ENV).to receive(:[]).with('RAILS_ENV') { 'test' }
      end

      context 'with TEST_DATABASE_URL set' do
        before do
          allow(ENV).to receive(:[]).with('TEST_DATABASE_URL') { 'abc' }
        end

        it { is_expected.to eql 'abc' }
      end

      context 'without TEST_DATABASE_URL set' do
        it { is_expected.to eql 'database-url' }
      end
    end

    context 'production' do
      before do
        allow(ENV).to receive(:[]).with('RAILS_ENV') { 'production' }
      end

      it { is_expected.to eql 'database-url' }
    end
  end

  describe '#docker_compose_path' do
    subject { environment.docker_compose_path(env).to_s }

    context 'default' do
      let(:env) { nil }
      it { is_expected.to end_with('docker-compose.development.yml') }
    end

    context 'test' do
      let(:env) { :test }
      it { is_expected.to end_with('docker-compose.test.yml') }
    end

    context 'production' do
      let(:env) { :production }
      it { is_expected.to end_with('docker-compose.production.yml') }
    end
  end

  describe '#docker_compose_config?' do
    let(:path) { environment.docker_compose_path(environment.environment) }

    context 'compose file exists' do
      before { FileUtils.touch(path) }
      after { FileUtils.rm_f(path) }
      its(:docker_compose_config?) { is_expected.to be true }
    end

    context 'compose file does not exist' do
      before { FileUtils.rm_f(path) }
      its(:docker_compose_config?) { is_expected.to be false }
    end
  end

  describe '#default_app_name' do
    subject(:default_app_name) { environment.default_app_name }
    it { is_expected.to eql 'dummy' }

    context 'Rails application not defined' do
      before do
        allow(Rails).to receive(:application) { Class.new(Object).new }
        allow(Dir).to receive(:pwd) { '/path/to/my_app' }
      end

      it { is_expected.to eql 'myapp' }
    end
  end

  describe '#settings' do
    subject(:settings) { environment.settings }
    it { is_expected.to be_a Orchestration::Settings }
  end
end
