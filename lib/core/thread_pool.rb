module SpaceStation
  class ThreadPool

    def initialize(queue, amount = 4)
      @queue = queue
      @pool = []
      @thread_amount = amount
    end

    def run!
      @thread_amount.times do
        @pool << spawn_thread
      end
      puts "THREAD POOL starting running....."
    end



    private

    def spawn_thread
      Thread.new do
        while true
          task = @queue.pop
          task.call
        end # while end
      end # thread end
    end

  end
end