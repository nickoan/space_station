require 'socket'
require 'json'

sock = Socket.new(:INET, :STREAM)
sockaddr = Socket.pack_sockaddr_in( 1234, '127.0.0.1' )
sock.connect(sockaddr)


a = {
    account: '123',
    channel: 'test',
    data: {
        message: 123
    }
}

sock.write("#{a.to_json}\r\n\r\n")

sleep(10)

sock.write("#{a.to_json}\r\n\r\n")

sleep(3)

value = nil
begin
  value = sock.read_nonblock(16 * 1028)
rescue => e
  puts e.full_message
  retry
end


puts value

sleep(2)

sock.close