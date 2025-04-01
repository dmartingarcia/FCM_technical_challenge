# spec/integration/main_spec.rb
# rubocop:disable RSpec/DescribeClass

require 'spec_helper'
require 'tempfile'
require 'open3'

RSpec.describe 'End-to-End Test' do
  let(:expected_output) do
    <<~OUTPUT
      TRIP to BCN
      Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10
      Hotel at BCN on 2023-01-05 to 2023-01-10
      Flight from BCN to SVQ at 2023-01-10 10:30 to 11:50

      TRIP to MAD
      Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
      Hotel at MAD on 2023-02-15 to 2023-02-17
      Train from MAD to SVQ at 2023-02-17 17:00 to 19:30

      TRIP to NYC
      Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
      Flight from BCN to NYC at 2023-03-02 15:00 to 22:45
    OUTPUT
  end
  let(:input_content) do
    <<~INPUT
      RESERVATION
      SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10

      RESERVATION
      SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10

      RESERVATION
      SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10
      SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50

      RESERVATION
      SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00
      SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30

      RESERVATION
      SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17

      RESERVATION
      SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45
    INPUT
  end

  it 'processes input file and produces correct output' do
    # Create temporary input file
    input_file = Tempfile.new('input').tap do |f|
      f.write(input_content)
      f.close
    end

    # Run the main script and capture output
    output, status = Open3.capture2(
      { 'BASED' => 'SVQ' },
      "bundle exec ruby main.rb #{input_file.path}"
    )

    expect(status).to be_success
    expect(output.strip).to eq(expected_output.strip)
  ensure
    input_file&.unlink
  end
end

# rubocop:enable RSpec/DescribeClass
