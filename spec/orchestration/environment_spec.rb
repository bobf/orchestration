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

  describe '#docker_compose_path' do
    subject { environment.docker_compose_path(env).to_s }

    context 'default' do
      let(:env) { nil }
      it { is_expected.to end_with('docker-compose.yml') }
    end

    context 'test' do
      let(:env) { :test }
      it { is_expected.to end_with('docker-compose.test.yml') }
    end

    context 'production' do
      let(:env) { :production }
      it { is_expected.to end_with('docker-compose.production.yml') }
    end

    context 'override' do
      let(:env) { :override }
      it { is_expected.to end_with('docker-compose.override.yml') }
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

  its(:default_application_name) { is_expected.to eql 'dummy' }

  describe '#settings' do
    subject(:settings) { environment.settings }
    it { is_expected.to be_a Orchestration::Settings }
  end
end
