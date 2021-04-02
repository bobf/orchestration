# frozen_string_literal: true

RSpec.describe Orchestration do
  it 'has a version number' do
    expect(Orchestration::VERSION).not_to be nil
  end

  it 'has a valid Makefile' do
    path = File.join('lib', 'orchestration', 'make')
    expect(`make -f orchestration.mk --no-print-directory -C #{path} _test`.chomp).to eql 'test command'
  end
end
