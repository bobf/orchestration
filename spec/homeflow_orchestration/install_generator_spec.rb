# frozen_string_literal: true

RSpec.describe HomeflowOrchestration::InstallGenerator do
  subject(:install_generator) { described_class.new }

  it { is_expected.to be_a described_class }
end
