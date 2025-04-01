# frozen_string_literal: true

require 'rspec'

RSpec.describe Core::UseCases::GroupSegmentsIntoTravels do
  subject(:segment_grouper) { described_class.new(segments, base) }

  let(:base) { 'SVQ' }
  let(:segments) do
    [
      Core::Entities::Flight.new(origin: 'SVQ', destination: 'BCN',
                                 start_time: DateTime.new(2023, 3, 2, 6, 40),
                                 end_time: DateTime.new(2023, 3, 2, 9, 10)),
      Core::Entities::Hotel.new(location: 'BCN',
                                start_time: DateTime.new(2023, 1, 5, 14),
                                end_time: DateTime.new(2023, 1, 10, 10)),
    ]
  end

  describe '#execute' do
    it 'groups segments into travels' do
      travels = segment_grouper.execute
      expect(travels.size).to eq(1)
      expect(travels.first.segments.size).to eq(1)
    end
  end
end
