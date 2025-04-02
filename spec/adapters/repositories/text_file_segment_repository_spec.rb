# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'date'

RSpec.describe Adapters::Repositories::TextFileSegmentRepository do
  let(:base_file_path) { 'spec/fixtures/input.txt' }
  let(:logger_instance) { Adapters::Loggers::NullLogger.new }

  describe '#new' do
    it 'initialize properly with the file path' do
      expect(described_class.new(base_file_path)).not_to be_nil
    end
  end

  describe '#find_all' do
    context 'with valid segments' do
      let(:valid_content) do
        <<~CONTENT
          SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10
          SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10
          SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00
        CONTENT
      end

      it 'parsed 3 elements' do
        Tempfile.create('input') do |f|
          f.write(valid_content)
          f.close

          repository = described_class.new(f.path)
          segments = repository.find_all

          expect(segments.size).to eq(3)
        end
      end

      it 'parses Hotel segment correctly' do
        Tempfile.create('input') do |f|
          f.write(valid_content)
          f.close

          repository = described_class.new(f.path)
          segments = repository.find_all

          hotel = segments[0]
          expect(hotel).to be_a(Core::Entities::Hotel)
          expect(hotel.location).to eq('BCN')
          expect(hotel.start_time).to eq(DateTime.new(2023, 1, 5, 0))
          expect(hotel.end_time).to eq(DateTime.new(2023, 1, 10, 0))
        end
      end

      it 'parses train segment correctly' do
        Tempfile.create('input') do |f|
          f.write(valid_content)
          f.close

          repository = described_class.new(f.path)
          segments = repository.find_all

          train = segments[1]
          expect(train).to be_a(Core::Entities::Train)
          expect(train.origin).to eq('SVQ')
          expect(train.destination).to eq('MAD')
          expect(train.start_time).to eq(DateTime.new(2023, 2, 15, 9, 30))
        end
      end

      it 'parses flight segment correctly' do
        Tempfile.create('input') do |f|
          f.write(valid_content)
          f.close

          repository = described_class.new(f.path)
          segments = repository.find_all

          flight = segments[2]
          expect(flight).to be_a(Core::Entities::Flight)
          expect(flight.origin).to eq('SVQ')
          expect(flight.destination).to eq('BCN')
          expect(flight.start_time).to eq(DateTime.new(2023, 3, 2, 6, 40))
          expect(flight.end_time).to eq(DateTime.new(2023, 3, 2, 9, 10))
        end
      end
    end

    context 'with overnight flights' do
      it 'handles next-day arrivals correctly' do
        content = 'SEGMENT: Flight NYC 2023-04-01 23:30 -> LON 02:15'

        Tempfile.create('input') do |f|
          f.write(content)
          f.close

          repository = described_class.new(f.path)
          flight = repository.find_all.first

          expect(flight.end_time).to eq(DateTime.new(2023, 4, 2, 2, 15))
        end
      end
    end

    context 'with invalid segments' do
      let(:invalid_content) do
        <<~CONTENT
          SEGMENT: InvalidType XXX 2023-01-01 -> YYY
          SEGMENT: Flight INVALID 2023-13-45 25:61 -> DEST 99:99
          SEGMENT: Hotel MISSING_DATE
        CONTENT
      end

      it 'skips invalid lines and logs errors' do
        Tempfile.create('input') do |f|
          f.write(invalid_content)
          f.close

          repository = described_class.new(f.path, logger_instance: logger_instance)
          segments = repository.find_all

          expect(segments).to be_empty
          expect(logger_instance.error_logs.size).to eq(3)
        end
      end
    end

    context 'with empty file' do
      it 'returns empty array' do
        Tempfile.create('input') do |f|
          repository = described_class.new(f.path)
          expect(repository.find_all).to eq([])
        end
      end
    end

    context 'with sorting functionality' do
      it 'orders segments by start time' do
        content = <<~CONTENT
          SEGMENT: Flight BCN 2023-05-02 10:00 -> MAD 11:00
          SEGMENT: Flight SVQ 2023-05-01 08:00 -> BCN 09:00
        CONTENT

        Tempfile.create('input') do |f|
          f.write(content)
          f.close

          repository = described_class.new(f.path)
          segments = repository.find_all

          expect(segments[0].origin).to eq('SVQ')
          expect(segments[1].origin).to eq('BCN')
        end
      end
    end

    context 'with mixed valid/invalid content' do
      let(:mixed_content) do
        <<~CONTENT
          SEGMENT: Flight SVQ 2023-06-01 07:00 -> BCN 08:30
          GARBAGE DATA
          SEGMENT: Hotel BCN 2023-06-01 -> 2023-06-05
        CONTENT
      end

      it 'processes valid segments and skips invalid lines' do
        Tempfile.create('input') do |f|
          f.write(mixed_content)
          f.close

          repository = described_class.new(f.path)
          segments = repository.find_all

          expect(segments.size).to eq(2)
          expect(segments[0]).to be_a(Core::Entities::Hotel)
          expect(segments[1]).to be_a(Core::Entities::Flight)
        end
      end
    end
  end

  describe 'error handling' do
    context 'with invalid date' do
      let(:invalid_content) do
        <<~CONTENT
          SEGMENT: Hotel BCN 2023-13-01 -> 2023-06-05
          SEGMENT: Hotel BCN 2023-06-01 -> 2023-06-05
        CONTENT
      end

      it 'raises InvalidDateError' do
        Tempfile.create('input') do |f|
          f.write(invalid_content)
          f.close

          segments = described_class.new(f.path, logger_instance: logger_instance).find_all
          expect(segments.size).to eq(1)
          expect(segments[0]).to be_a(Core::Entities::Hotel)
          expect(logger_instance.error_logs.join).to include('Invalid date 2023-13-01')
        end
      end
    end

    context 'with non-existent file' do
      it 'raises FileReadError' do
        expect do
          described_class.new('non_existent.txt').find_all
        end.to raise_error(Core::Errors::FileReadError)
      end
    end
  end
end
