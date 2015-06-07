require_relative '../common'

class Message

  def Message.send_msg(message_info)
    # комната, хеш, сообщение
    # проверить, есть ли права, есть ли такой польз, отправить в соответствующий комнате канал сообщение
    return trigger_error(1, 'Нет полей id, hash, message') unless message_info.respond_to?('key') &&
        message_info.key?('id') &&
        message_info.key?('hash') &&
        message_info.key?('message')

    return trigger_error(14, 'Недостаточно прав') unless have_rights_usr?(message_info)

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