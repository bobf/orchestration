# frozen_string_literal: true

RSpec.describe Orchestration::Services::Database::Configuration do
  let(:config_path) do
    Orchestration.root.join('spec', 'dummy', 'config', 'database.yml')
  end

  subject(:configuration) { described_class.new(config_path) }

  it { is_expected.to be_a described_class }

  describe '#settings' do
    subject(:settings) { configuration.settings }

    context 'sqlite3' do
      let(:config_path) { fixture('sqlite3') }

      its(['adapter']) { is_expected.to eql 'sqlite3' }
      its(['host']) { is_expected.to be_nil }
      its(['database']) { is_expected.to eql 'healthcheck' }
      its(['username']) { is_expected.to eql '' }
      its(['password']) { is_expected.to eql '' }
      its(['pool']) { is_expected.to eql 5 }
      its(['timeout']) { is_expected.to eql 5000 }
    end

    context 'postgresql' do
      let(:config_path) { fixture('postgresql') }

      its(['adapter']) { is_expected.to eql 'postgresql' }
      its(['host']) { is_expected.to eql 'localhost' }
      its(['database']) { is_expected.to eql 'postgres' }
      its(['username']) { is_expected.to eql 'postgres' }
      its(['password']) { is_expected.to eql 'password' }
      its(['port']) { is_expected.to eql 5432 }
    end

    context 'mysql2' do
      let(:config_path) { fixture('mysql2') }

      its(['adapter']) { is_expected.to eql 'mysql2' }
      its(['host']) { is_expected.to eql 'localhost' }
      its(['database']) { is_expected.to eql 'mysql' }
      its(['username']) { is_expected.to eql 'root' }
      its(['password']) { is_expected.to eql 'password' }
      its(['pool']) { is_expected.to eql 5 }
    end

    context 'DATABASE_URL' do
      let(:config_path) { fixture('postgresql') }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV)
          .to receive(:[])
          .with('DATABASE_URL')
          .and_return(database_url)
      end

      context 'host override' do
        let(:database_url) { 'postgres://custom.host' }

        its(['adapter']) { is_expected.to eql 'postgresql' }
        its(['host']) { is_expected.to eql 'custom.host' }
        its(['database']) { is_expected.to eql 'postgres' }
        its(['username']) { is_expected.to eql 'postgres' }
        its(['password']) { is_expected.to eql 'password' }
      end

      context 'port override' do
        let(:database_url) { 'postgres://:5678' }

        its(['adapter']) { is_expected.to eql 'postgresql' }
        its(['host']) { is_expected.to eql 'localhost' }
        its(['database']) { is_expected.to eql 'postgres' }
        its(['username']) { is_expected.to eql 'postgres' }
        its(['password']) { is_expected.to eql 'password' }
        its(['port']) { is_expected.to eql 5678 }
      end
    end

    context 'RAILS_ENV' do
      let(:config_path) { fixture('postgresql') }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV)
          .to receive(:[])
          .with('RAILS_ENV')
          .and_return('production')
      end

      its(['adapter']) { is_expected.to eql 'postgresql' }
      its(['host']) { is_expected.to eql 'database.company.org' }
      its(['database']) { is_expected.to eql 'postgres' }
      its(['username']) { is_expected.to eql 'postgres' }
      its(['password']) { is_expected.to eql 'password' }
    end
  end

  def fixture(name)
    Orchestration.root.join('spec', 'fixtures', "#{name}.yml")
  end
end
