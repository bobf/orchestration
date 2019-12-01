# frozen_string_literal: true

RSpec.describe Orchestration::Terminal do
  subject(:terminal) { described_class.new }

  it { is_expected.to be_a described_class }

  describe '#write' do
    subject(:write) { terminal.write(*args) }

    before { allow(STDOUT).to receive(:print) }

    context 'with description and message' do
      let(:args) { [:status, 'message'] }
      it 'writes colorised output to stdout' do
        expect(STDOUT)
          .to receive(:print)
          .with("\e[0;34;49m         status\e[0m message\n")
        write
      end
    end

    context 'with description, message, and custom colour reference' do
      let(:args) { [:status, 'message', :ready] }
      it 'writes colorised output to stdout' do
        expect(STDOUT)
          .to receive(:print)
          .with("\e[0;32;49m         status\e[0m message\n")
        write
      end
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
