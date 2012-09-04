zmq  = require 'zmq'

exports.connect = (ss, host, port) ->
  sub = zmq.socket 'sub'
  sub.subscribe 'metric'
  sub.subscribe 'alert'
  sub.connect "tcp://#{host}:#{port}" 
  sub.on 'message', (data) ->
    msg         = data.toString().split(' ')
    channel     = msg[0]
    event_data  = JSON.parse(msg[1])
    ss.api.publish.all(channel, event_data)
