class Protocol

  attr_reader :name, :commands, :clients

  def initialize (protocol_name)
    @name = protocol_name
    @commands = {}
    @clients = EM::Channel.new()
  end

  def command (cmd, &block)
    @commands[cmd] = block
  end

  def execute (cmd, data, client)
    if @commands.has_key? cmd
      @commands[cmd].call(self, data, client, @clients)
    else
      throw "#{cmd} is not defined"
    end
  end

  def push (target, command, data)
    packet = {:command => command, :data => data}.to_json
    if target.is_a? EM::Channel
      target.push(packet)
    else
      target.send(packet)
    end
  end

  def subscribe (client, &block)
    @clients.subscribe(client, &block)
  end

  def unsubscribe (sid)
    @clients.unsubscribe(sid)
  end

end