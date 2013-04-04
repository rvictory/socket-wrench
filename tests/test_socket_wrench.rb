require_relative '../lib/socket_wrench'
require 'sinatra'

EventMachine.run do
  class Server < Sinatra::Base
    configure do
      set :server, :thin
      set :port, 9000

      socket = SocketWrench.new(9001)
      socket.get_protocol("test").command("update") do |protocol, data, client, channel|
        # Send updates to all clients in the channel
        protocol.push(channel, "update", data)
      end
      socket.begin_listening
    end

    get '/' do
      erb :index
    end

    Server.run!({:port => 9000})

  end
end
