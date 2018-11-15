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
      temp_client_list = Set.new

      @clients_list.each do |c|
        next if c.closed? || c.client_id == @client.client_id
        begin
          c.write_nonblock(@body.to_json)
        rescue IO::WaitWritable
          temp_client_list << c
        rescue EOFError
        end
      end

      if temp_client_list.size > 0 && @remain_count <= SpaceStation::Task::DEFAULT_REMAIN_TIMES
        @task_state = :remain
        @clients_list = temp_client_list
        @remain_count += 1
      else
        @task_state = :complete
      end
    end

  end
end