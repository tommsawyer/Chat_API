require_relative '../common'
require 'singleton'

class Message
  include Singleton

  def send_msg(message_info, ws)
    channel = $channels.find_by_room(message_info['id'])

    return trigger_error(14, 'Нет такой комнаты') unless channel

    channel.push(JSON.generate({
      :type => 'message',
      :data => {
          :room_id       => message_info['id'],
          :nickname => User.find_by(login: decrypt_hash(message_info['hash']))[:login],
          :message  => message_info['message']
      }
    }).to_s)

    {
        :type => 'message_success',
        :data => {}
    }

  end

end