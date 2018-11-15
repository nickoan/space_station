require 'set'

module SpaceStation
  class Client

    attr_accessor :state

    attr_reader :client_id, :channel_list

    def initialize(socket, state = :unknown)
      @socket = socket
      @state = state
      @channel_list = Set.new
      @client_id = generate_client_id
      @parser = Parser.new
      @chunk = []
      @mutex = Mutex.new
    end

    def channel_name=(name)
      raise StateIsUnKnown if @state == :unknown
      @channel_list << name
    end

    def to_io
      @socket.to_io
    end

    def read_nonblock
      str = @socket.read_nonblock(16 * 1024)
      if @parser.end?(str)
        if !@chunk.empty?
          str = @chunk.join << str
          @chunk = []
        end
        return @parser.serialize(str)
      end
      @chunk << str
      nil
    end

    def write_nonblock(str)
      @mutex.synchronize do
        @socket.write_nonblock(str)
      end
    end

    def close
      @socket.close
    end

    def closed?
      @socket.closed?
    end

    private

    def generate_client_id
      "#{(Time.now.to_f * 1000).to_i}-#{@socket.addr.last}"
    end
  end
end