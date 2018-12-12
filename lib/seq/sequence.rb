module SpaceStation
  class Sequence

    attr_reader :need_asyc

    def initialize(client, body, channel_manger)
      @client = client
      @body = body
      @channel_manger = channel_manger
      @need_asyc = false
    end

    def call
      raise Exception, 'not impl any method'
    end

    private

    def log(type)
      puts "[#{type}] #{@client.client_id}: #{@body.to_json}"
    end
  end
end