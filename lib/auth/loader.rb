module SpaceStation
  module Auth
    class Loader

      def initialize(options)
        @redis ||= Redis.new(host:options[:redis_host],
                           port: options[:redis_port],
                           password: options[:redis_password],
                           timeout: options[:redis_timeout])
      end

      # permissions
      # account name as redis key
      # {
      #     seq: ['publish', 'subscribe'],
      #     channels: ['abcd']
      # }

      def checkout(account_name)
        permission = @redis.get(account_name)
        return if permission.nil?

        auth_obj = JSON.parse(permission, symbolize_names: true)

        account = Account.new(account_name)
        account.permissions = auth_obj

        account
      end
    end
  end
end