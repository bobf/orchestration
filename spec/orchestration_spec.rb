# frozen_string_literal: true

RSpec.describe Orchestration do
  it 'has a version number' do
    expect(Orchestration::VERSION).not_to be nil
  end

  describe 'Makefile' do
    let(:tmp_path) { Pathname.new(File.join(Dir.tmpdir, SecureRandom.hex(4), 'Makefile')) }
    let(:source) { Pathname.new(File.join('lib', 'orchestration', 'make', 'orchestration.mk')) }

    before do
      tmp_path.parent.mkdir
      tmp_path.write(source.read)
      tmp_path.dirname.join('.orchestration.yml').write(fixture('config.yml').read)
    end

    after { tmp_path.dirname.rmtree }

    it 'has a valid Makefile' do
      make_cmd = "make --no-print-directory -C #{tmp_path.dirname} _test"
      expect(`#{make_cmd}`.chomp).to eql 'test command'
    end
  end
end
