require 'set'
require 'json'

module SpaceStation
  class Client

    attr_accessor :state, :message_queue

    attr_reader :client_id, :channel_list

    attr_writer :monitor

    def initialize(socket, state = :unknown)
      @socket = socket
      @state = state
      @channel_list = Set.new
      @client_id = generate_client_id
      @parser = WebsocketParser.new(socket)
      @channel_manager = nil
      @message_queue = []
      @write_chunk = ''
      @client_own_mutex = Mutex.new
      @monitor = nil
    end

    def channel_name=(name)
      raise StateIsUnKnown if @state == :unknown
      @channel_list << name
    end

    def response_message=(msg)
      @client_own_mutex.synchronize do
        @message_queue.push(msg)
        @monitor.add_interest(:w) unless @monitor.writable? || @monitor.closed?
      end
    end

    def remove_w_interest_if_needed
      @client_own_mutex.synchronize do
        if @monitor.writable? && @message_queue.empty? && @write_chunk.empty?
          @monitor.remove_interest(:w)
        end
      end
    end

    def to_io
      @socket.to_io
    end

    def channel_manager=(cm)
      @channel_manager ||= cm
      @channel_manager.register_to_channel(@channel_list, self)
    end

    def handshake
      begin
        str = @socket.read_nonblock(16 * 1024)
        handshake_msg = @parser.handshake_request(str) do |headers|
          topics = headers['topics']
          if topics
            @channel_list.merge(topics.split(',').map { |v| v.strip.to_sym })
          end
        end

        if handshake_msg
          @write_chunk = handshake_msg
          @state = :active
        end
      rescue IO::WaitReadable
      end
    end

    def message=(msg)
      @message_queue << @parser.transfer_message(msg)
    end

    def read_nonblock

      begin
        str = @socket.read_nonblock(16 * 1024)
        @parser.push_to_parse(str)
        temp = []

        while value = @parser.read
          break if value.nil?
          temp << JSON.parse(value, symbolize_names: true)
        end
        temp
      rescue IO::WaitReadable
        #stub nothing to do now
      rescue Errno::ECONNRESET
      end
    end

    # do not using in multi threads
    def write_response
      return if @message_queue.empty? && @write_chunk.empty?

      # may have remain from last write
      @write_chunk = @parser.out_transfer_message(@message_queue.shift) if @write_chunk.empty?

      begin
        remain_index = @socket.write_nonblock(@write_chunk)
        @write_chunk = @write_chunk[remain_index..-1]
      rescue IO::WaitWritable
        # stub nothing to do
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