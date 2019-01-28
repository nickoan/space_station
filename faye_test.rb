require 'faye/websocket'
require 'eventmachine'
require 'json'

EM.run {

  ws = Faye::WebSocket::Client.new('ws://127.0.0.1:8999')
  ws.headers['account'] = "my_test1"
  
  ws.on :open do |event|
    p [:open]
    ws.send({channels: ["abcd"], seq: :subscribe, data: {}}.to_json)
    sleep(3)
    #ws.send({channel: ["abcd"], seq: :unsubscribe, data: {}}.to_json)
    str = ''
    #5000.times do str << Time.now.to_s end
    ws.send({channels: ["abcd"], seq: :publish, data: {str: str}}.to_json)
  end

  ws.on :message do |event|
    p [:message, event.data]
    ws.send({channels: ["abcd"], seq: :publish, data: {}}.to_json)
    sleep(2)
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}