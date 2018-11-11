# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose do
  let(:init_options) { {} }

  subject(:docker_compose) { described_class.new(init_options) }

  it { is_expected.to be_a described_class }

  its(:structure) do
    is_expected.to eql('version' => '3.7', 'services' => {})
  end

  describe "#structure['services']" do
    subject(:services) { docker_compose.structure['services'] }

    it { is_expected.to be_a Hash }

    describe "['database']" do
      subject(:database) { services['database'] }

      let(:init_options) { { database: database_config } }
      let(:database_config) do
        Orchestration::Healthchecks::Database::Configuration.new(
          fixture(adapter)
        )
      end

      context 'postgresql' do
        let(:adapter) { 'postgresql' }

        it { is_expected.to be_a Hash }
        its(['image']) { is_expected.to eql 'library/postgres' }
        its(['environment']) do
          is_expected.to eql(
            'PGPORT' => 5499, 'POSTGRES_PASSWORD' => 'password'
          )
        end
      end

      context 'mysql2' do
        let(:adapter) { 'mysql2' }

        it { is_expected.to be_a Hash }
        its(['image']) { is_expected.to eql 'library/mysql' }
        its(['environment']) do
          is_expected.to eql(
            'MYSQL_ROOT_PASSWORD' => 'password',
            'MYSQL_TCP_PORT' => 3399
          )
        end
      end

      context 'sqlite3' do
        let(:adapter) { 'sqlite3' }

        it { is_expected.to be_nil }
      end
    end
  end

  def fixture(name)
    Orchestration.root.join('spec', 'fixtures', "#{name}.yml")
  end
end
