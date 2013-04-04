require 'em-websocket'
require 'json'
require_relative 'protocol'

class SocketWrench

  def initialize (port)
    @port = port
    @protocols = {}
  end

  def get_protocol (name)
    @protocols[name] = @protocols[name] || Protocol.new(name)
    @protocols[name]
  end

  def execute (protocol, data, client)
    data = JSON.parse(data)
    puts data.inspect
    protocol.execute(data['command'], data['data'], client)
  end

  def begin_listening
    EM.run do
      EM::WebSocket.run(:host => "0.0.0.0", :port => @port) do |ws|
        ws.onopen do |handshake|
          puts "WebSocket connection open: #{handshake.path.sub("/", "")}"
          protocol = get_protocol(handshake.path.sub('/', ''))
          sid = protocol.subscribe(ws) do |msg|
            ws.send(msg)
          end

          ws.onmessage do |msg|
            execute(protocol, msg, ws)
          end

          ws.onclose do
            protocol.unsubscribe(sid)
          end

        end
      end
    end
  end

end