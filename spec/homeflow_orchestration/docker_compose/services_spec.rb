# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::Services do
  let(:init_options) { {} }

  subject(:services) { described_class.new(init_options) }

  it { is_expected.to be_a described_class }

  its(:structure) do
    is_expected.to eql('version' => '3.7', 'services' => {})
  end
end
