# frozen_string_literal: true

RSpec.describe Orchestration do
  it 'has a version number' do
    expect(Orchestration::VERSION).not_to be nil
  end
end
