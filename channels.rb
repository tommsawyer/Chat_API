require 'em-websocket'

class Listener
  attr_accessor :sid, :websocket
end

class Channel
  attr_accessor :listeners, :channel, :creator, :room_id

  def initialize(creator, room_id)
    self.listeners = []
    self.channel = EM::Channel.new
    self.creator = creator
    self.room_id = room_id
  end

  def subscribe(websocket)
    listener = Listener.new
    listener.websocket = websocket
    listener.sid = self.channel.subscribe {|msg| listener.websocket.send msg}
    self.listeners << listener
  end

  def unsubscribe(websocket)
    self.listeners.each {
      |listener|
      if listener.websocket == websocket
        self.channel.unsubscribe(listener.sid)
        listeners.delete(listener)
        break
      end
    }
  end

  def push(message)
    self.channel.push message
  end

  def number_of_listeners
    self.listeners.length
  end
end

class Channels
  attr_accessor :channels

  def initialize
    self.channels = []
  end

  def create_channel(creator, room_id)
    self.channels << Channel.new(creator, room_id)
  end

  def remove_channel(room_id)
    channels.each do |channel|
      if channel.room_id == room_id
        channels.delete(channel)
        break
      end
    end
  end

  def find_by_room(room_id)
    channels.each do |channel|
        return channel if channel.room_id == room_id
    end
    nil
  end

  def unsubscribe(websocket)
    p channels
    self.channels.each do |channel|
      channel.unsubscribe(websocket)
    end
  end
end
