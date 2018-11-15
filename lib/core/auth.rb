module SpaceStation
  class Auth
    def initialize(redis)
      @redis = redis
    end

    def check_auth(channel, account)
      return true
      auth_arr = @redis.get(account)
      JSON.parse(auth_arr).include?(channel)
    end
  end
end