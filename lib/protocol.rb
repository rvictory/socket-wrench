class Protocol

  attr_reader :name, :commands, :clients, :caller, :data

  def initialize (protocol_name)
    @name = protocol_name
    @commands = {}
    @clients = EM::Channel.new()
    @caller = nil
    @data = nil
  end

  def on (cmd, &block)
    @commands[cmd] = block
  end

  def execute (cmd, data, client)
    if @commands.has_key? cmd
      @data = data
      @caller = client
      instance_eval(&@commands[cmd])
      #@commands[cmd].call(self, data, client, @clients)
    else
      throw "#{cmd} is not defined"
    end
  end

  def push (target, command, data)
    packet = {:command => command, :data => data}.to_json
    return if target.nil?
    if target.is_a? EM::Channel
      target.push(packet)
    else
      target.send(packet)
    end
  end

  def send_to_channel (command, data)
    push(@clients, command, data)
  end

  def send_to_client (command, data)
    push(@caller, command, data)
  end

  def subscribe (client, &block)
    @clients.subscribe(client, &block)
  end

  def unsubscribe (sid)
    @clients.unsubscribe(sid)
  end

end