require 'em-websocket'
require_relative 'models/user'

class Listener
  attr_accessor :sid, :websocket, :user_id, :nickname
end

class Channel
  attr_accessor :listeners, :channel, :creator, :room_id

  def initialize(creator, room_id)
    self.listeners = []
    self.channel = EM::Channel.new
    self.creator = creator
    self.room_id = room_id
  end

  def subscribe(websocket, user_id=nil)
    listener = Listener.new
    listener.user_id = user_id
    listener.nickname = User.find_by(id: user_id)
    if listener.nickname
      self.channel.push(JSON.generate({
                            :type => 'user_join',
                            :data => {
                                :nickname => listener.nickname[:login],
                                :id => listener.nickname[:id]
                            }
                        }))
      listener.nickname = listener.nickname[:login]
    end
    listener.websocket = websocket
    listener.sid = self.channel.subscribe { |msg| listener.websocket.send msg }
    self.listeners << listener


  end

  def unsubscribe(websocket)
    self.listeners.each {
        |listener|
      if listener.websocket == websocket
        if listener.user_id
          self.channel.push(JSON.generate({
                                              :type => 'user_leave',
                                              :data => {
                                                  :nickname => listener.nickname,
                                                  :id => listener.user_id
                                              }
                                          }))
        end
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

  def get_authorized_users
    users = []
    listeners.each do |listener|
      if listener.user_id
        users << {
            :id => listener.user_id,
            :nickname => listener.nickname
        }
      end
    end
    users
  end
end

class Channels
  attr_accessor :channels

  def initialize
    self.channels = []
  end

  def create_channel(creator, room_id)
    self.channels << Channel.new(creator, room_id)
    p channels
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
    self.channels.each do |channel|
      return channel if channel.room_id == room_id
    end
    nil
  end

  def unsubscribe(websocket)
    self.channels.each do |channel|
      channel.unsubscribe(websocket)
    end
  end

  def in_room?(channel, websocket)
    channel.listeners.each do |listener|
      return true if listener.websocket == websocket
    end
    false
  end
end
