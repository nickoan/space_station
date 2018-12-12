module SpaceStation
  class Unsubscribe < Sequence

    def call
      channels = @body[:channel]
      @channel_manger.deregister(channels, @client)
      log(:unsubscribe)
    end

  end
end