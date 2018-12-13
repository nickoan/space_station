require 'socket'
require 'nio'

module SpaceStation
  class Engine

    def initialize
      @config = Config.new
      @options = @config.options

      @selector = NIO::Selector.new
      @channels_manager = ChannelManager.new
      @client_pool = []

      @host = @options[:host] || '127.0.0.1'
      @port = @options[:port] || 1234

      @running = true
      @server = TCPServer.new(@host, @port)
      @selector = NIO::Selector.new
      @selector.register(@server, :r)

      @tasks_queue = Queue.new
      @thread_pool = ThreadPool.new(@tasks_queue)
    end

    def run!

      puts "service start... Listen At: #{@host}:#{@port}"
      @thread_pool.run!

      while @running

        ios = @selector.select(2)

        next if ios.nil?

        ios.each do |m|

          case m.io

          when TCPServer

            begin
              sock = m.io.accept_nonblock
              next if sock.nil?
            rescue IO::WaitReadable
            rescue => ex
              puts ex.full_message
            end

            client = Client.new(sock)
            @client_pool << client
            @selector.register(client, :r)
            log(:connect, client)
          when ::SpaceStation::Client
            client = m.io

            if client.closed?
              disconnect_from_client(client)
              next
            end

            if client.state != :active
              begin
                client.handshake
                if client.state == :active
                  m.add_interest(:w)
                  client.channel_manager = @channels_manager
                  log(:pass_handshake, client)
                end
              rescue EOFError
                client.close
                disconnect_from_client(client)
              end
            else

              if m.writable?
                client.write_response
              end
              read_from_client(client)
            end

          end
        end

      end
    end

    private

    def read_from_client(client)
      begin
        bodies = client.read_nonblock
        return if bodies.nil? || bodies.empty?

        bodies.each do |body|
          operate_with_client(client, body)
        end
        true
      rescue EOFError
        client.close
        disconnect_from_client(client)
      rescue => ex
        puts ex.full_message
        client.close
        disconnect_from_client(client)
      end
    end

    def disconnect_from_client(client)
      @selector.deregister(client)
      @channels_manager.deregister(client.channel_list, client)
      @client_pool.delete(client)
      log(:disconnect, client)
    end

    def operate_with_client(client, body)
      async_task = SeqSelector.select(client, body, @channels_manager).call
      @tasks_queue.push(async_task) if async_task
    end

    def log(action, client)
      puts "[\033[1;32m#{action}\033[0m] #{client.client_id}: #{Time.now}"
    end

  end
end
