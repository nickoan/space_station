module SpaceStation
  class Publish < Sequence

    prepend AsyncSequence

    def call

      channels = @body[:channel]

      pack = channels.map { |channel| @channel_manger.find_channel(channel) }

      Proc.new do
        pack.each do |clients|
          clients.each do |c|
            next if c.client_id == @client.client_id
            c.message_queue << @body
          end
        end
        log(:publish)
      end
    end

  end
end