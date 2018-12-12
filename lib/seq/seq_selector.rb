
module SpaceStation

  module SeqLoader

    def init_seq_warehouse
      @warehouse = Hash.new if @warehouse.nil?
    end

    def set_seq(name, handler)
      @warehouse[name.to_sym] = handler
    end

    def choose(name)
      @warehouse[name.to_sym]
    end

  end


  class SeqSelector

    extend SeqLoader

    init_seq_warehouse

    set_seq :publish, Publish
    set_seq :subscribe, Subscribe
    set_seq :unsubscribe, Unsubscribe

    def self.select(client, body, channel_manger)
      seq = body[:seq]
      klass = SeqSelector.choose(seq)
      klass.new(client, body, channel_manger)
    end
  end
end