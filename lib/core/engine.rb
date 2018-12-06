require 'socket'
require 'nio'

module SpaceStation
  class Engine

    def initialize(options)

      @options = options.dup

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

      @auth_checker = Auth.new(Redis.new(
          host: @options[:redis_host],
          port: @options[:redis_port],
          password: @options[:redis_password]
      ))

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
            puts "client id: #{client.client_id} trying to connect"
            #read_from_client(client)
          when ::SpaceStation::Client
            client = m.io

            if client.closed?
              disconnect_from_client(client)
              next
            end

            if client.state != :active
              begin
                client.handshake
                m.add_interest(:w) if client.state == :active
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
          operate_with_client(client, body, body[:channel])
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
      puts @client_pool.size
      @client_pool.delete(client)
      puts "client id: #{client.client_id} disconnected"
    end

    def operate_with_client(client, body, channel)
      task = Task.new(channel, body, client)
      task.prepare(@channels_manager.find_channel(body[:channel]), :broadcast)
      @tasks_queue.push(task)
    end

  end
end