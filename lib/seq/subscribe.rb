module SpaceStation
  class Subscribe < Sequence

    def call
      channels = @body[:topics]
      return if channels.nil?
      @channel_manger.register_to_channel(channels, @client)
      log(:subscribe)
    end

  end
end