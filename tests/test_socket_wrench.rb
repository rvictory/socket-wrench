require_relative '../lib/socket_wrench'
require 'sinatra'

EventMachine.run do

  class Server < Sinatra::Base

    configure do

      set :server, :thin
      set :port, 9000

      @@user_list = []

      @@socket = SocketWrench.new(9001)

      @@socket.protocol("chat") do

        on "update" do
          # Send updates to all clients in the channel
          send_to_channel("update", data)
        end

        on "join" do
          unless @@user_list.include? data['username']
            # Tell the client the user list
            send_to_client("user_list", {'list' => @@user_list})
            @@user_list.push(data['username'])
            # Tell the channel that somebody joined
            send_to_channel("join", data)
          end
        end

        on "leave" do
          if @@user_list.include? data['username']
            # Tell the channel that somebody left
            send_to_channel("leave", data)
            @@user_list.delete(data['username'])
          end
        end

        on "username_check" do
          send_to_client("username_check", @@user_list.include?(data['username']))
        end

      end

      @@socket.begin_listening

    end

    get '/' do
      erb :index
    end

    Server.run!({:port => 9000})
  end

end
