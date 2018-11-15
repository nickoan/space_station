require 'json'

module SpaceStation
  class Parser

    attr_reader :parse_type

    def initialize
      @parse_type = :json
      @parse_engine = JSON
    end

    def parse(str)
      @parse_engine.parse(str, symbolize_names: true)
    end
    alias serialize parse

    def end?(str)
      str.end_with?("\r\n\r\n")
    end
  end
end