module SpaceStation
  class Publish < Sequence

    prepend AsyncSequence

    def call
      Proc.new do
        channels = @body[:channel]

        channels.each do |channel|
          clients = @channel_manger.find_channel(channel)

          clients.each do |c|
            c.message_queue << @body
          end
        end
        log(:publish)
      end
    end

  end
end