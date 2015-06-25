require_relative '../common'
require_relative '../models/message'
require 'singleton'

class Messages
  include Singleton

  def send_msg(message_info, ws)
    channel = $channels.find_by_room(message_info['room_id'])

    return trigger_error(20, 'You arent in this room') unless $channels.in_room?(channel, ws)

    user = User.find_by(token: message_info['token'])

    Message.create(
               sender: user[:id],
               recipient: message_info['room_id'],
               message: message_info['message']
    )

    channel.push(JSON.generate({
      :type => 'message',
      :data => {
          :room_id  => message_info['room_id'],
          :nickname => user[:login],
          :message  => message_info['message']
      }
    }).to_s)

    {
        :type => 'message_success',
        :data => {}
    }

  end
end