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

      @auth_loader = Auth::Loader.new(@options) if @config.enable?(:auth)
    end

    def config_file=(path)
      @config.file_path(path)
    end

    def config_file_type=(type)
      @config.file_type(type)
    end

    def start!
      begin
        run!
      rescue Interrupt
        puts 'space station ending now..........'
      rescue => ex
        log(:error_occur, ex.full_message)
      end
    end

    private

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
            end

            client = Client.new(sock)
            @client_pool << client
            monitor = @selector.register(client, :r)
            client.monitor = monitor
            log(:connect, client)

          when ::SpaceStation::Client
            client = m.io

            if client.closed?
              disconnect_from_client(client)
              next
            end

            if client.state == :fail
              client.write_response
              client.close
              disconnect_from_client(client)
            end

            if client.state != :active
              begin
                client.handshake(@auth_loader)
                if client.state == :active
                  m.add_interest(:w)
                  client.channel_manager = @channels_manager
                  log(:pass_handshake, client)

                elsif client.state == :fail
                  client.write_response
                  log(:fail_handshake, client)
                  client.close
                  disconnect_from_client(client)
                end
              rescue EOFError
                client.close
                disconnect_from_client(client)
              end
            else

              if m.writable?
                client.write_response
                client.remove_w_interest_if_needed
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
      begin
        async_task = SeqSelector.select(client, body, @channels_manager).call
        @tasks_queue.push(async_task) if async_task
      rescue PermissionDeniedError => ex
        client.response_message =  {error: true, message: ex.message}.to_json
      end
    end

    def log(action, client)
      puts "[\033[1;31m#{action}\033[0m] #{client.client_id}: #{Time.now}"
    end

  end
end
