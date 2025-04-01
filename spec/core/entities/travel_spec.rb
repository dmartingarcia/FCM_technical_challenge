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
    it 'returns the destination of a two way travel' do
      travel = described_class.new(
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
        )
      ])

      expect(travel.destination).to eq('BCN')
    end

    it 'returns the destination of a one way travel' do
      travel = described_class.new(
        base: 'SVQ',
        segments: [
        Core::Entities::Flight.new(
          origin: 'SVQ',
          destination: 'BCN',
          start_time: DateTime.new(2023, 3, 2, 6, 40),
          end_time: DateTime.new(2023, 3, 2, 9, 10)
        )
      ])

      expect(travel.destination).to eq('BCN')
    end

    #Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
    #Hotel at MAD on 2023-02-15 to 2023-02-17
    #Train from MAD to SVQ at 2023-02-17 17:00 to 19:30

    it 'it gathers the destination from a travel that includes a layover/stopover connection (24 h max)' do
      travel = Core::Entities::Travel.new(
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
      ])

      expect(travel.destination).to eq('MAD') # 'MAD' is still the last destination
      expect(travel.destination).to eq('MAD') # If the base matches the last destination, return it
    end

    it 'returns the base parameter when no transport segments exist' do
      segments = [
        Core::Entities::Hotel.new(
          location: 'MAD',
          start_time: DateTime.new(2023, 3, 4, 6, 40),
          end_time: DateTime.new(2023, 3, 5, 9, 10)
        )
      ]
      travel = Core::Entities::Travel.new(base: 'MAD', segments: segments)
      expect(travel.destination).to eq('BCN')
    end
  end
end
