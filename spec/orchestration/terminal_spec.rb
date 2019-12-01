# frozen_string_literal: true

RSpec.describe Orchestration::Terminal do
  subject(:terminal) { described_class.new(settings) }

  let(:settings) { instance_double(Orchestration::Settings) }

  it { is_expected.to be_a described_class }

  describe '#write' do
    subject(:write) { terminal.write(*args) }

    before { allow(STDOUT).to receive(:print) }

    context 'with description and message' do
      let(:args) { [:status, 'message'] }
      it 'writes colorised output to stdout' do
        expect(STDOUT)
          .to receive(:print)
          .with("\e[34m         status\e[0m message\n")
        write
      end
    end

    context 'with description, message, and custom colour reference' do
      let(:args) { [:status, 'message', :ready] }
      it 'writes colorised output to stdout' do
        expect(STDOUT)
          .to receive(:print)
          .with("\e[32m         status\e[0m message\n")
        write
      end
    end
  end

  describe '#read' do
    subject(:read) { terminal.read(prompt, default) }

    let(:input) { 'input' }
    let(:default) { nil }
    let(:prompt) { 'prompt' }

    before do
      allow(STDIN).to receive(:gets) { input }
      allow(STDOUT).to receive(:print)
    end

    it { is_expected.to eql 'input' }

    context 'default response' do
      context 'no input' do
        let(:default) { 'default' }
        let(:input) { '' }
        it { is_expected.to eql 'default' }
      end

      context 'input given' do
        let(:default) { 'value' }
        let(:input) { 'input' }
        it { is_expected.to eql 'input' }
      end

      context 'blank input given' do
        let(:default) { 'value' }
        let(:input) { '   ' }
        it { is_expected.to eql 'value' }
      end
    end

    context 'trailing/leading whitespace' do
      let(:input) { '    input    ' }
      it { is_expected.to eql 'input' }
    end

    context 'prompt' do
      context 'without default' do
        let(:default) { nil }

        it 'writes a given prompt message' do
          expect(STDOUT).to receive(:print).with(any_args) do |arg|
            expect(arg).to end_with '(prompt): '
          end

          read
        end
      end

      context 'with default' do
        let(:default) { 'value' }

        it 'writes a given prompt message including default value' do
          expect(STDOUT).to receive(:print).with(any_args) do |arg|
            expect(arg).to end_with '(prompt) [default: value]: '
          end

          read
        end
      end
    end
  end

  describe '#ask_setting' do
    subject(:ask_setting) { terminal.ask_setting(setting, default) }

    let(:setting) { 'foo' }
    let(:default) { 'value' }

    before do
      allow(settings).to receive(:get)
      allow(settings).to receive(:set)
      allow(STDIN).to receive(:gets) { '' }
      allow(STDOUT).to receive(:print)
    end

    it 'stores a given setting' do
      allow(STDIN).to receive(:gets) { 'input' }
      expect(settings).to receive(:set).with('foo', 'input')
      ask_setting
    end

    it 'uses default when blank input given' do
      allow(STDIN).to receive(:gets) { '  ' }
      expect(settings).to receive(:set).with('foo', 'value')
      ask_setting
    end

    it 'uses translation file to produce prompt' do
      allow(I18n).to receive(:t)
      expect(I18n).to receive(:t).with('orchestration.settings.foo.prompt')
      ask_setting
    end

    it 'uses translation file to produce description' do
      allow(I18n).to receive(:t)
      expect(I18n).to receive(:t).with('orchestration.settings.foo.description')
      ask_setting
    end
  end

  shared_examples 'a recognised color reference' do |color_reference|
    subject(:write) { terminal.write(color_reference, 'message') }
    it 'is a recognised colour reference' do
      expect(STDOUT).to receive(:print)
      write
    end
  end

  %i[
    failure
    error
    waiting
    ready
    create
    update
    status
    setup
    input
    skip
  ].each { |color| it_behaves_like 'a recognised color reference', color }

  context 'unrecognised color' do
    subject(:write) { terminal.write(:nonexistent, 'message') }

    it 'raises an error' do
      expect { write }.to raise_error(KeyError)
    end
  end
end
