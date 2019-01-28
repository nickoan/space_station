module SpaceStation
  module Auth
    class Account

      attr_reader :name

      attr_writer :permissions

      def initialize(name)
        @name = name
        @state = :unauth
      end

      def check_seq(body)
        seq = body[:seq]
        case seq
        when 'publish', 'subscribe'
          raise PermissionDeniedError, "#{seq} not allowed" unless @permissions[:seq].include?(seq.to_s)
          check_channels(body[:channels])
        else
          raise UnknownSequenceTypeError, "known sequence #{seq}"
        end
      end

      def check_channels(channels)
        if channels.is_a?(Array)
          channels.each do |channel|
            raise PermissionDeniedError, "#{channel.to_s} permission denied" unless
                @permissions[:channels].include?(channel.to_s)
          end
        else
          raise PermissionDeniedError, "#{channels.to_s} permission denied" unless
              @permissions[:channels].include?(channels.to_s)
        end
      end

      def active!
        @state = :active
      end

      def inactive!
        @state = :inactive
      end

      def active?
        @state == :active
      end

      def inactive?
        @state == :inactive
      end
    end
  end
end