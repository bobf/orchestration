# frozen_string_literal: true

RSpec.describe Orchestration::DockerCompose::Services do
  subject(:services) { described_class.new(env, init_options) }

  let(:env) do
    instance_double(
      Orchestration::Environment,
      public_volume: 'myapp_public'
    )
  end
  let(:init_options) { {} }

  it { is_expected.to be_a described_class }

  its(:structure) do
    is_expected.to eql(
      'version' => '3.7',
      'services' => {},
      'volumes' => { 'myapp_public' => nil }
    )
  end
end
