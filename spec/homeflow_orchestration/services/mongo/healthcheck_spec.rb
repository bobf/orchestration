# frozen_string_literal: true

RSpec.describe Orchestration::Services::Mongo::Healthcheck do
  subject(:healthcheck) { described_class.new }

  it { is_expected.to be_a described_class }
end
