module SpaceStation
  class ChannelManager

    def initialize
      @channels = {}
    end

    def register_to_channel(channels, client)
      channels.each do |channel|
        insert(channel.to_sym, client)
      end
    end

    def find_channel(channel_name)
      @channels[channel_name.to_sym].dup
    end

    def deregister(client_channels, client)
      client_channels.each do |c|
        @channels[c.to_sym].delete(client)
      end
    end

    private

    def insert(channel_name, client)

      if @channels[channel_name].nil?
        @channels[channel_name] = Set.new
      end

      @channels[channel_name] << client
    end
  end
end