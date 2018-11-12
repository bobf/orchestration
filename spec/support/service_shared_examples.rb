# frozen_string_literal: true

RSpec.shared_examples 'a service' do |service|
  describe 'healthcheck' do
    subject(:healthcheck) { service::Healthcheck }
    it { is_expected.to respond_to :start }
  end

  describe 'configuration' do
    subject(:configuration) { service::Configuration.new }
    it { is_expected.to respond_to :settings }
  end
end
