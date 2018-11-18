# frozen_string_literal: true

RSpec.describe Orchestration::Environment do
  subject(:environment) { described_class.new }

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
  end
end
