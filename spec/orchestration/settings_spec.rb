# frozen_string_literal: true

RSpec.describe Orchestration::Settings do
  subject(:settings) do
    described_class.new(path)
  end

  before { FileUtils.rm_f(path) }

  let(:path) { File.join(Dir.tmpdir, '.orchestration.yml') }

  describe '#get' do
    before do
      File.write(path, { 'docker' => { 'username' => 'dockeruser' } }.to_yaml)
    end

    let(:path) { Orchestration.root.join('spec', 'fixtures', 'config.yml') }
    subject(:get) { settings.get(key) }
    context 'docker.username' do
      let(:key) { 'docker.username' }
      it { is_expected.to eql 'dockeruser' }
    end
  end

  describe '#set' do
    subject(:set) { settings.set(key, value) }
    context 'docker.username' do
      let(:key) { 'docker.username' }
      let(:value) { 'testuser' }

      it 'sets a value' do
        set
        expect(settings.get(key)).to eql value
      end
    end
  end

  describe 'dirty?' do
    subject(:dirty?) { settings.dirty? }
    context 'unchanged' do
      it { is_expected.to be false }
    end

    context 'changed' do
      before { settings.set('test.key', 'foobar') }
      it { is_expected.to be true }
    end
  end

  describe 'exist?' do
    subject(:exist?) { settings.exist? }

    context 'file exists' do
      before { FileUtils.touch(path) }
      it { is_expected.to be true }
    end

    context 'file does not exist' do
      before { FileUtils.rm_f(path) }
      it { is_expected.to be false }
    end
  end
end
