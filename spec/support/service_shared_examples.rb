# frozen_string_literal: true

RSpec.shared_examples 'a service' do |service|
  describe 'healthcheck' do
    subject(:healthcheck) { service::Healthcheck }
    it { is_expected.to respond_to :start }
  end

  describe 'configuration' do
    subject(:configuration) { service::Configuration.new(env) }

    let(:env) do
      double(
        'Environment',
        environment: 'test',
        database_url: nil,
        database_configuration_path: fixture('sqlite3'),
        mongoid_configuration_path: fixture('mongoid')
      )
    end

    it { is_expected.to respond_to :settings }
  end

  def fixture(name)
    Orchestration.root.join('spec', 'fixtures', "#{name}.yml")
  end
end
