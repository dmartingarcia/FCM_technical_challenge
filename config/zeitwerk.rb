require 'zeitwerk'

module FcmTechnicalChallenge
  class Loader
    @setup = nil

    def self.setup
      @setup ||= begin
        loader = Zeitwerk::Loader.new

        # Add zeitwerk on the actual project root dir
        loader.push_dir(Dir.pwd)

        # Configure namespace
        loader.inflector = Zeitwerk::GemInflector.new("#{__dir__}/..")

        # Optional: Custom inflection rules
        loader.inflector.inflect(
          'iata' => 'IATA'
        )

        # Finalize setup
        loader.setup
        loader.eager_load if ENV['RACK_ENV'] == 'production'

        loader
      end
    end
  end
end
