# frozen_string_literal: true

RSpec.describe Orchestration::Services::Database::Adapters::Mysql2 do
  its(:name) { is_expected.to eql 'mysql2' }
  its(:image) { is_expected.to eql 'library/mysql' }
  its(:credentials) do
    is_expected.to eql(
      'username' => 'root',
      'password' => 'password',
      'database' => 'mysql'
    )
  end

  its(:errors) { is_expected.to eql [::Mysql2::Error] }
  its(:default_port) { is_expected.to eql 3306 }
  its(:environment) do
    is_expected.to eql(
      'MYSQL_ROOT_PASSWORD' => 'password'
    )
  end

  its(:data_dir) { is_expected.to eql '/var/lib/mysql' }
end
