require 'faye/websocket'
require 'eventmachine'
require 'json'

EM.run {

  ws = Faye::WebSocket::Client.new('ws://127.0.0.1:1234')
  
  ws.on :open do |event|
    p [:open]
    ws.send({channel: "default", data: {}}.to_json)
  end

  ws.on :message do |event|
    p [:message, event.data]
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}