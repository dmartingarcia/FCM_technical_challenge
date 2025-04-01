# frozen_string_literal: true

require 'rspec'

RSpec.describe Core::UseCases::GroupSegmentsIntoTravels do
  subject(:travels) { described_class.new(segments, base).execute }

  let(:base) { 'SVQ' }
  let(:segments) do
    # Reservation 1
    [
      Core::Entities::Flight.new(
        origin: 'SVQ',
        destination: 'BCN',
        start_time: DateTime.new(2023, 3, 2, 6, 40),
        end_time: DateTime.new(2023, 3, 2, 9, 10)
      ),
      # Reservation 2
      Core::Entities::Hotel.new(
        location: 'BCN',
        start_time: DateTime.new(2023, 1, 5),
        end_time: DateTime.new(2023, 1, 10)
      ),
      # Reservation 3 (Two flight segments)
      Core::Entities::Flight.new(
        origin: 'SVQ',
        destination: 'BCN',
        start_time: DateTime.new(2023, 1, 5, 20, 40),
        end_time: DateTime.new(2023, 1, 5, 22, 10)
      ),
      Core::Entities::Flight.new(
        origin: 'BCN',
        destination: 'SVQ',
        start_time: DateTime.new(2023, 1, 10, 10, 30),
        end_time: DateTime.new(2023, 1, 10, 11, 50)
      ),
      # Reservation 4 (Two train segments)
      Core::Entities::Train.new(
        origin: 'SVQ',
        destination: 'MAD',
        start_time: DateTime.new(2023, 2, 15, 9, 30),
        end_time: DateTime.new(2023, 2, 15, 11, 0)
      ),
      Core::Entities::Train.new(
        origin: 'MAD',
        destination: 'SVQ',
        start_time: DateTime.new(2023, 2, 17, 17, 0),
        end_time: DateTime.new(2023, 2, 17, 19, 30)
      ),
      # Reservation 5
      Core::Entities::Hotel.new(
        location: 'MAD',
        start_time: DateTime.new(2023, 2, 15),
        end_time: DateTime.new(2023, 2, 17)
      ),
      # Reservation 6
      Core::Entities::Flight.new(
        origin: 'BCN',
        destination: 'NYC',
        start_time: DateTime.new(2023, 3, 2, 15, 0),
        end_time: DateTime.new(2023, 3, 2, 22, 45)
      ),
    ]
  end

  describe '#execute' do
    it 'groups segments into 3 travels' do
      # Expect three trips
      expect(travels.size).to eq(3)
    end

    it 'First travel (BCN) contains the expected segments' do
      # Verify the trip destined to BCN
      trip_to_bcn = travels.detect { |trip| trip.destination == 'BCN' }

      expect(trip_to_bcn).not_to be_nil
      expect(trip_to_bcn.segments.size).to eq(3)
      expect(trip_to_bcn.segments[0]).to have_attributes(
        origin: 'SVQ',
        destination: 'BCN',
        start_time: DateTime.new(2023, 1, 5, 20, 40),
        end_time: DateTime.new(2023, 1, 5, 22, 10)
      )
      expect(trip_to_bcn.segments[1]).to have_attributes(
        location: 'BCN',
        start_time: DateTime.new(2023, 1, 5),
        end_time: DateTime.new(2023, 1, 10)
      )
      expect(trip_to_bcn.segments[2]).to have_attributes(
        origin: 'BCN',
        destination: 'SVQ',
        start_time: DateTime.new(2023, 1, 10, 10, 30),
        end_time: DateTime.new(2023, 1, 10, 11, 50)
      )
    end

    it 'Second travel (MAD) contains the expected segments' do
      # Verify the trip destined to MAD
      trip_to_mad = travels.detect { |trip| trip.destination == 'MAD' }
      expect(trip_to_mad).not_to be_nil
      expect(trip_to_mad.segments.size).to eq(3)
      expect(trip_to_mad.segments[0]).to have_attributes(
        origin: 'SVQ',
        destination: 'MAD',
        start_time: DateTime.new(2023, 2, 15, 9, 30),
        end_time: DateTime.new(2023, 2, 15, 11, 0)
      )
      expect(trip_to_mad.segments[1]).to have_attributes(
        location: 'MAD',
        start_time: DateTime.new(2023, 2, 15),
        end_time: DateTime.new(2023, 2, 17)
      )
      expect(trip_to_mad.segments[2]).to have_attributes(
        origin: 'MAD',
        destination: 'SVQ',
        start_time: DateTime.new(2023, 2, 17, 17, 0),
        end_time: DateTime.new(2023, 2, 17, 19, 30)
      )
    end

    it 'Third travel (NYC) contains the expected segments' do
      # Verify the trip destined to NYC
      trip_to_nyc = travels.detect { |trip| trip.destination == 'NYC' }
      expect(trip_to_nyc).not_to be_nil
      expect(trip_to_nyc.segments.size).to eq(2)
      expect(trip_to_nyc.segments[0]).to have_attributes(
        origin: 'SVQ',
        destination: 'BCN',
        start_time: DateTime.new(2023, 3, 2, 6, 40),
        end_time: DateTime.new(2023, 3, 2, 9, 10)
      )
      expect(trip_to_nyc.segments[1]).to have_attributes(
        origin: 'BCN',
        destination: 'NYC',
        start_time: DateTime.new(2023, 3, 2, 15, 0),
        end_time: DateTime.new(2023, 3, 2, 22, 45)
      )
    end
  end
end
