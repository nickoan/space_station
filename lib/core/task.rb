module SpaceStation
  class Task

    attr_reader :channel, :body, :task_state

    DEFAULT_REMAIN_TIMES = 3

    def initialize(channel, body, client)
      @channel = channel.to_sym
      @body = body
      @client = client
      @task_state = :waiting
      @remain_count = 0
    end

    def prepare(clients, task_type)
      @task = task_type
      @clients_list = clients
    end

    def call
      begin
        send(@task)
      rescue => ex
        puts "TASK EXCEPTION: #{ex.full_message}"
      end
    end


    def complete?
      @task_state == :complete
    end

    def remain?
      @task_state == :remain
    end

    def waiting?
      @task_state == :waiting
    end

    private

    def broadcast
      @client.message_queue << @body
      @task_state = :complete
    end

  end
end