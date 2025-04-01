require 'spec_helper'
require 'date'

RSpec.describe Core::Entities::Travel do
  describe '#add_segment' do
    it 'adds a segment to the travel' do
      travel = described_class.new(base: 'SVQ')
      segment = Core::Entities::Flight.new(
        origin: 'SVQ',
        destination: 'BCN',
        start_time: DateTime.new(2023, 3, 2, 6, 40),
        end_time: DateTime.new(2023, 3, 2, 9, 10)
      )

      travel.add_segment(segment)

      expect(travel.segments).to include(segment)
      expect(travel.segments.size).to eq(1)
    end
  end

  describe '#destination' do
    context 'with two way travel' do
      # Gathered from the README.md
      # Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
      # Hotel at MAD on 2023-02-15 to 2023-02-17
      # Train from MAD to SVQ at 2023-02-17 17:00 to 19:30

      let(:travel) do
        described_class.new(
          base: 'SVQ',
          segments: [
            Core::Entities::Flight.new(
              origin: 'SVQ',
              destination: 'BCN',
              start_time: DateTime.new(2023, 3, 2, 6, 40),
              end_time: DateTime.new(2023, 3, 2, 9, 10)
            ),
            Core::Entities::Train.new(
              origin: 'BCN',
              destination: 'SVQ',
              start_time: DateTime.new(2023, 3, 3, 12, 0),
              end_time: DateTime.new(2023, 3, 3, 14, 30)
            ),
          ]
        )
      end

      it 'returns the destination' do
        expect(travel.destination).to eq('BCN')
      end
    end

    context 'with a one-way travel' do
      # Gathered from the README.md
      # TRIP to NYC
      # Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
      # Flight from BCN to NYC at 2023-03-02 15:00 to 22:45
      let(:travel) do
        described_class.new(
          base: 'SVQ',
          segments: [
            Core::Entities::Flight.new(
              origin: 'SVQ',
              destination: 'BCN',
              start_time: DateTime.new(2023, 3, 2, 6, 40),
              end_time: DateTime.new(2023, 3, 2, 9, 10)
            ),
            Core::Entities::Flight.new(
              origin: 'BCN',
              destination: 'NYC',
              start_time: DateTime.new(2023, 3, 2, 15, 0),
              end_time: DateTime.new(2023, 3, 2, 22, 45)
            ),
          ]
        )
      end

      it 'returns the destination of the travel' do
        expect(travel.destination).to eq('NYC')
      end
    end

    context 'with one travel' do
      let(:travel) do
        described_class.new(
          base: 'SVQ',
          segments: [
            Core::Entities::Flight.new(
              origin: 'SVQ',
              destination: 'BCN',
              start_time: DateTime.new(2023, 3, 2, 6, 40),
              end_time: DateTime.new(2023, 3, 2, 9, 10)
            ),
          ]
        )
      end

      it 'returns the destination of the travel' do
        expect(travel.destination).to eq('BCN')
      end
    end

    context 'with a travel that includes a layover/stopover connection (24 h max)' do
      let(:travel) do
        described_class.new(
          base: 'SVQ',
          segments: [
            Core::Entities::Flight.new(
              origin: 'SVQ',
              destination: 'BCN',
              start_time: DateTime.new(2023, 3, 2, 6, 40),
              end_time: DateTime.new(2023, 3, 2, 9, 10)
            ),
            Core::Entities::Train.new(
              origin: 'BCN',
              destination: 'MAD',
              start_time: DateTime.new(2023, 3, 3, 9, 0),
              end_time: DateTime.new(2023, 3, 3, 14, 30)
            ),
            Core::Entities::Flight.new(
              origin: 'MAD',
              destination: 'SVQ',
              start_time: DateTime.new(2023, 3, 4, 6, 40),
              end_time: DateTime.new(2023, 3, 5, 9, 10)
            ),
          ]
        )
      end

      it 'returns the destination of the travel' do
        expect(travel.destination).to eq('MAD') # 'MAD' is the last destination
      end
    end

    it 'returns the base parameter when no transport segments exist' do
      segments = [
        Core::Entities::Hotel.new(
          location: 'MAD',
          start_time: DateTime.new(2023, 3, 4, 6, 40),
          end_time: DateTime.new(2023, 3, 5, 9, 10)
        ),
      ]

      travel = described_class.new(base: 'MAD', segments: segments)
      expect(travel.destination).to eq('MAD')
    end
  end
end
