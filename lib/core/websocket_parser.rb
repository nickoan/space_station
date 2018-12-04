require 'websocket'

module SpaceStation
  class WebsocketParser

    def initialize(socket)
      @socket = socket
      @handshake = WebSocket::Handshake::Server.new
      @state = :not_finish
      @request_message = nil
      @current_original_data = nil
    end

    def pass_auth?
      @state == :pass_auth
    end

    def handshake_request(str)

      if @state == :not_finish
        @handshake << str
      end

      if @handshake.finished?
        raise NotPassAuthError unless @handshake.valid?

        yield @handshake.headers if block_given?

        @state = :pass_auth

        @control_frame = WebSocket::Frame::Incoming::Server.new

        return @handshake.to_s
      end
    end

    def out_transfer_message(data)
      WebSocket::Frame::Outgoing::Server.new(version: @handshake.version, data: data, type: :text).to_s
    end

    def push_to_parse(data)
      @control_frame << data
    end

    def read
      result = @control_frame.next
      return unless result
      result.to_s
    end
  end
end