require_relative '../lib/socket_wrench'
require 'sinatra'

EventMachine.run do

  class Server < Sinatra::Base

    configure do

      set :server, :thin
      set :port, 9000

      @@user_list = []

      @@socket = SocketWrench.new(9001)

      @@socket.get_protocol("chat").command("update") do |protocol, data, client, channel|
        # Send updates to all clients in the channel
        protocol.push(channel, "update", data)
      end

      @@socket.get_protocol("chat").command("join") do |protocol, data, client, channel|
        unless @@user_list.include? data['username']
          # Tell the client the user list
          protocol.push(client, "user_list", {'list' => @@user_list})
          @@user_list.push(data['username'])
          # Tell the clients that somebody joined
          protocol.push(channel, "join", data)

        end
      end

      @@socket.get_protocol("chat").command("leave") do |protocol, data, client, channel|
        if @@user_list.include? data['username']
          # Tell the clients that somebody joined
          protocol.push(channel, "leave", data)
          @@user_list.delete(data['username'])
        end
      end

      @@socket.get_protocol("chat").command("username_check") do |protocol, data, client, channel|
        protocol.push(client, "username_check", @@user_list.include?(data['username']))
      end

      @@socket.begin_listening

    end

    get '/' do
      erb :index
    end

    Server.run!({:port => 9000})
  end

end
