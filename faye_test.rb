require 'faye/websocket'
require 'eventmachine'
require 'json'

EM.run {

  ws = Faye::WebSocket::Client.new('ws://127.0.0.1:8999')
  
  ws.on :open do |event|
    p [:open]
    ws.send({channel: ["abcd"], seq: :subscribe, data: {}}.to_json)
    sleep(1)
    #ws.send({channel: ["abcd"], seq: :unsubscribe, data: {}}.to_json)
    str = ''
    #5000.times do str << Time.now.to_s end
    ws.send({channel: ["abcd"], seq: :publish, data: {str: str}}.to_json)
  end

  ws.on :message do |event|
    p [:message, event.data]
    ws.send({channel: ["abcd"], seq: :publish, data: {}}.to_json)
    sleep(0.3)
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}