RSpec.describe Orchestration::DatabaseHealthcheck do
  let(:database_healthcheck) { described_class.new }

  subject { database_healthcheck }

  it { is_expected.to be_a described_class }
end
