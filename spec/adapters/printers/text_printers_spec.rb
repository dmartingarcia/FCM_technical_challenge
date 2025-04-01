# frozen_string_literal: true

require 'spec_helper'
require 'date'

RSpec.describe Adapters::Printers::TextPrinter do
  let(:base) { 'SVQ' }
  let(:printer) { described_class.new(travels, base, logger_instance: logger_instance) }
  let(:logger_instance) { Adapters::Loggers::StdoutLogger.new }

  describe '#print' do
    # Subject that captures stdout
    subject(:output) do
      $stdout = StringIO.new
      printer.print
      $stdout.string
    ensure
      $stdout = STDOUT
    end

    context 'with multiple trips' do
      let(:travels) do
        [
          Core::Entities::Travel.new(
            segments: [
              Core::Entities::Flight.new(
                origin: 'SVQ',
                destination: 'BCN',
                start_time: DateTime.new(2023, 3, 2, 6, 40),
                end_time: DateTime.new(2023, 3, 2, 9, 10)
              ),
              Core::Entities::Hotel.new(
                location: 'BCN',
                start_time: DateTime.new(2023, 3, 2, 14, 0),
                end_time: DateTime.new(2023, 3, 5, 10, 0)
              ),
            ]
          ),
          Core::Entities::Travel.new(
            segments: [
              Core::Entities::Train.new(
                origin: 'SVQ',
                destination: 'MAD',
                start_time: DateTime.new(2023, 2, 15, 9, 30),
                end_time: DateTime.new(2023, 2, 15, 11, 0)
              ),
            ]
          ),
        ]
      end

      it 'groups trips by destination with proper formatting' do
        expected_output = <<~OUTPUT
          TRIP to BCN
          Flight from SVQ to BCN at 2023-03-02 06:40 to 2023-03-02 09:10
          Hotel at BCN on 2023-03-02 to 2023-03-05

          TRIP to MAD
          Train from SVQ to MAD at 2023-02-15 09:30 to 2023-02-15 11:00

        OUTPUT

        expect(output).to eq(expected_output)
      end
    end

    context 'with empty travels' do
      let(:travels) { [] }

      it 'prints nothing' do
        expect(output).to be_empty
      end
    end

    context 'with different segment types' do
      let(:travels) do
        [
          Core::Entities::Travel.new(
            segments: [
              Core::Entities::Flight.new(
                origin: 'SVQ',
                destination: 'TST',
                start_time: DateTime.new(2023, 1, 1, 12, 0),
                end_time: DateTime.new(2023, 1, 1, 14, 0)
              ),
              Core::Entities::Train.new(
                origin: 'TST',
                destination: 'SVQ',
                start_time: DateTime.new(2023, 1, 2, 8, 0),
                end_time: DateTime.new(2023, 1, 2, 10, 0)
              ),
              Core::Entities::Hotel.new(
                location: 'TST',
                start_time: DateTime.new(2023, 1, 1, 14, 0),
                end_time: DateTime.new(2023, 1, 3, 10, 0)
              ),
            ]
          ),
        ]
      end

      it 'formats all segment types correctly' do
        expect(output).to include('Flight from SVQ to TST')
        expect(output).to include('Train from TST to SVQ')
        expect(output).to include('Hotel at TST')
      end
    end

    context 'with overnight segments' do
      let(:travels) do
        [
          Core::Entities::Travel.new(
            segments: [
              Core::Entities::Flight.new(
                origin: 'SVQ',
                destination: 'NYC',
                start_time: DateTime.new(2023, 4, 1, 23, 30),
                end_time: DateTime.new(2023, 4, 2, 2, 15)
              ),
            ]
          ),
        ]
      end

      it 'shows correct date transitions' do
        expect(output).to include('2023-04-01 23:30 to 2023-04-02 02:15')
      end
    end
  end

  describe 'error handling' do
    context 'with invalid segment type' do
      let(:travels) do
        [
          Core::Entities::Travel.new(
            segments: [instance_double(InvalidSegment)]
          ),
        ]
      end

      it 'raises appropriate error' do
        expect { printer.print }.to raise_error(Core::Errors::UnknownSegmentTypeError)
      end
    end
  end
end
