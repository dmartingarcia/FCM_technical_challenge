# frozen_string_literal: true

require 'rspec'

RSpec.describe Core::UseCases::GroupSegmentsIntoTravels do
  let(:travels) { described_class.new(segments, base).execute }
  let(:base) { 'SVQ' }
  let(:segments) do
    [
      # TRIP to BCN
      # Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10
      # Hotel at BCN on 2023-01-05 to 2023-01-10
      # Flight from BCN to SVQ at 2023-01-10 10:30 to 11:50
      Core::Entities::Flight.new(
        origin: 'SVQ',
        destination: 'BCN',
        start_time: DateTime.new(2023, 1, 5, 20, 40),
        end_time: DateTime.new(2023, 1, 5, 22, 10)
      ),
      Core::Entities::Hotel.new(
        location: 'BCN',
        start_time: DateTime.new(2023, 1, 5),
        end_time: DateTime.new(2023, 1, 10)
      ),
      Core::Entities::Flight.new(
        origin: 'BCN',
        destination: 'SVQ',
        start_time: DateTime.new(2023, 1, 10, 10, 30),
        end_time: DateTime.new(2023, 1, 10, 11, 50)
      ),
      # TRIP to MAD
      # Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
      # Hotel at MAD on 2023-02-15 to 2023-02-17
      # Train from MAD to SVQ at 2023-02-17 17:00 to 19:30
      Core::Entities::Train.new(
        origin: 'SVQ',
        destination: 'MAD',
        start_time: DateTime.new(2023, 2, 15, 9, 30),
        end_time: DateTime.new(2023, 2, 15, 11, 0o0)
      ),
      Core::Entities::Hotel.new(
        location: 'MAD',
        start_time: DateTime.new(2023, 2, 15),
        end_time: DateTime.new(2023, 2, 17)
      ),
      Core::Entities::Train.new(
        origin: 'MAD',
        destination: 'SVQ',
        start_time: DateTime.new(2023, 2, 17, 17, 0),
        end_time: DateTime.new(2023, 2, 17, 19, 30)
      ),
      # TRIP to NYC
      # Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
      # Flight from BCN to NYC at 2023-03-02 15:00 to 22:45
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
  end

  describe '#execute' do
    context 'with empty list of segments' do
      let(:segments) { [] }

      it 'returns an error after validation' do
        expect { travels }.to raise_error(Core::Errors::EmptyItineraryError)
      end
    end

    it 'groups segments into 3 travels' do
      # Expect three travels
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

    context 'when segments contain just a Hotel reservation' do
      let(:segments) do
        [
          Core::Entities::Hotel.new(
            location: 'SVQ',
            start_time: DateTime.new(2023, 1, 5),
            end_time: DateTime.new(2023, 1, 10)
          ),
        ]
      end

      it 'returns a travel with just the hotel' do
        expect(travels.size).to eq(1)
        expect(travels.first.segments[0]).to have_attributes(
          location: 'SVQ',
          start_time: DateTime.new(2023, 1, 5),
          end_time: DateTime.new(2023, 1, 10)
        )
      end
    end

    context "when there's multiple stopovers and layover plus overnights" do
      let(:segments) do
        [
          # Flight SVQ -> BCN (overnight)
          Core::Entities::Flight.new(
            origin: 'SVQ',
            destination: 'BCN',
            start_time: DateTime.new(2024, 1, 2, 20, 40),
            end_time: DateTime.new(2024, 1, 3, 2, 10)
          ),

          # Flight BCN -> BER
          Core::Entities::Flight.new(
            origin: 'BCN',
            destination: 'BER',
            start_time: DateTime.new(2024, 1, 3, 10, 30),
            end_time: DateTime.new(2024, 1, 3, 11, 50)
          ),

          # Flight BER -> AMS
          Core::Entities::Flight.new(
            origin: 'BER',
            destination: 'AMS',
            start_time: DateTime.new(2024, 1, 3, 14, 30),
            end_time: DateTime.new(2024, 1, 3, 16, 50)
          ),

          # Hotel in AMS
          Core::Entities::Hotel.new(
            location: 'AMS',
            start_time: DateTime.new(2024, 1, 3, 14, 0),  # Check-in at 14:00
            end_time: DateTime.new(2024, 1, 4, 10, 0)     # Check-out at 10:00
          ),

          # Flight AMS -> BCN (overnight)
          Core::Entities::Flight.new(
            origin: 'AMS',
            destination: 'BCN',
            start_time: DateTime.new(2024, 1, 4, 20, 40),
            end_time: DateTime.new(2024, 1, 5, 2, 10)
          ),

          # Flight BCN -> SVQ
          Core::Entities::Flight.new(
            origin: 'BCN',
            destination: 'SVQ',
            start_time: DateTime.new(2024, 1, 5, 10, 40),
            end_time: DateTime.new(2024, 1, 5, 16, 10)
          ),
        ]
      end

      it 'groups into a single travel' do
        expect(travels.count).to eq(1)
      end

      describe 'the single travel' do
        let(:travel) { travels.first }

        it 'has all 6 segments' do
          expect(travel.segments.count).to eq(6)
        end

        it 'has destination AMS' do
          expect(travel.destination).to eq('AMS')
        end
      end
    end
  end
end
