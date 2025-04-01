require_relative 'config/zeitwerk'
FcmTechnicalChallenge::Loader.setup

base = ENV.fetch('BASED', 'SVQ')

begin
  repository = Adapters::Repositories::TextFileSegmentRepository.new(ARGV[0])
  segments = repository.find_all_sorted
  travels = Core::UseCases::GroupSegmentsIntoTravels.new(segments, base).execute
  Adapters::Printers::TextSegmentPrinter.new(travels).print
rescue Core::Errors::FileReadError => e
  abort "Fatal file error: #{e.message}"
rescue Core::Errors::EmptyItineraryError
  abort 'No travel segments found in input file'
rescue Core::Errors::InvalidSegmentError, Core::Errors::InvalidDateError => e
  abort "Data validation error: #{e.message}"
end
