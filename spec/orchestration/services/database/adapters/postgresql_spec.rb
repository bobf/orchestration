# frozen_string_literal: true

RSpec.describe Orchestration::Services::Database::Adapters::Postgresql do
  its(:name) { is_expected.to eql 'postgresql' }
  its(:image) { is_expected.to eql 'library/postgres' }
  its(:credentials) do
    is_expected.to eql(
      'username' => 'postgres',
      'password' => 'password',
      'database' => 'postgres'
    )
  end

  its(:errors) { is_expected.to eql [PG::ConnectionBad] }
  its(:default_port) { is_expected.to eql 5432 }
  its(:environment) do
    is_expected.to eql(
      'POSTGRES_PASSWORD' => 'password',
      'PGDATA' => '/var/pgdata'
    )
  end

  its(:data_dir) { is_expected.to eql '/var/pgdata' }
end
