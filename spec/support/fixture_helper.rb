# frozen_string_literal: true

module FixtureHelper
  def fixture(name, extension = 'yml')
    File.read(fixture_path(name, extension))
  end

  def fixture_path(name, extension = 'yml')
    HomeflowOrchestration.root.join('spec', 'fixtures', "#{name}.#{extension}")
  end
end
