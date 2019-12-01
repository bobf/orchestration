# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::ComposeConfiguration do
  subject(:compose_configuration) { described_class.new(env) }

  let(:env) { instance_double(Orchestration::Environment) }

  describe '#services' do
    subject(:services) { compose_configuration.services }
  end

  describe '#database_adapter_name' do
    subject(:name) { compose_configuration.database_adapter_name }
    it { is_expected.to eql 'postgresql' }
  end

  describe '#database_adapter' do
    subject(:adapter) { compose_configuration.database_adapter }

    context 'postgresql' do
      before { hide_const('Mysql2') }
      before { hide_const('SQLite3') }
      let(:adapters) { Orchestration::Services::Database::Adapters }
      it { is_expected.to be_a adapters::Postgresql }
    end

    context 'mysql2' do
      before { hide_const('PG') }
      before { hide_const('SQLite3') }
      let(:adapters) { Orchestration::Services::Database::Adapters }
      it { is_expected.to be_a adapters::Mysql2 }
    end

    context 'sqlite3' do
      before { hide_const('PG') }
      before { hide_const('Mysql2') }
      let(:adapters) { Orchestration::Services::Database::Adapters }
      it { is_expected.to be_a adapters::Sqlite3 }
    end
  end

  describe '#local_port' do
    subject(:local_port) { compose_configuration.local_port(service) }
    let(:service) { 'test' }
    before do
      allow(env).to receive(:docker_compose_config) do
        {
          'services' => { 'test' => { 'ports' => ['1234:9999'] } }
        }
      end
    end

    it { is_expected.to eql 1234 }
  end
end
