require_relative '../common'
require_relative '../models/room'
require_relative '../models/user_role'
require_relative '../models/user_room'
require_relative '../models/user_room'


class Rooms

  def Rooms.create_room(room_info)
    return trigger_error(1, 'Нет полей hash, name, type') unless room_info.respond_to?('key') &&
        room_info.key?('hash') &&
        room_info.key?('name') &&
        room_info.key?('type')
    return trigger_error(14, 'Недостаточно прав') unless have_rights_usr?(room_info)

    creator = User.find_by(login: decrypt_hash(room_info['hash']))

    id = Room.create(
            name: room_info['name'],
            creator: creator['id'],
            roomType: room_info['type']
    )[:room_id]

    $channels.create_channel(creator[:id], id)

    {
      :type => 'create_success',
      :data => {
          :room_id => id
      }
    }

  end

  def Rooms.join_room(room_info, ws)
    return trigger_error(1, 'Нет полей id') unless room_info.respond_to?('key') &&
        room_info.key?('id')

    # Пользователь не должен состоять в этой комнате

    return trigger_error(20, 'Нет такой комнаты!') unless room = Room.find_by(id: room_info['id'])
    if room_info.key?('hash')
      user = User.find_by(login: decrypt_hash(room_info['hash']))
    end

    $channels.find_by_room(room[:id]).subscribe(ws, (user == nil) ? nil : user[:id])

    {
      :type => 'join',
      :data => {
          :success => true
      }
    }
  end

  def Rooms.get_users(room_info)
    return trigger_error(1, 'Нет полей id, hash') unless room_info.respond_to?('key') &&
        room_info.key?('id') &&
        room_info.key?('hash')

    return trigger_error(20, 'Нет такой комнаты!') unless room = Room.find_by(id: room_info['id'])
    {
        :type => 'users',
        :data => {
            :id    => room_info['id'],
            :users => $channels.find_by_room(room_info['id'].to_i).get_authorized_users,
        }
    }
  end

  def Rooms.exit_room()

  end

  def Rooms.get_rooms(room_info)
    return trigger_error(1, 'Нет полей start или end') unless room_info.respond_to?('key') &&
        room_info.has_key?('start') &&
        room_info.has_key?('end')

    rooms = []
    count = 0

    if room_info['start']==0 && room_info['end']==0
      Room.all.each do |u|
        rooms << {
            :room_id => u[:id],
            :name => u[:name],
            :type => u[:roomType]
        }
        count += 1
      end
      return {
          :type => 'rooms',
          :data => {
              :total => count,
              :amount => count,
              :rooms => rooms
          }
      }
    end

    # добавить проверку start и end
    # правильно подсчитывать total

    Room.where(id: room_info['start']..room_info['end']).each do |u|
      rooms << {
          :room_id => u[:id],
          :name => u[:name],
          :type => u[:roomType]
      }
      count += 1
    end

    {
        :type => 'rooms',
        :data => {
            :total => count,
            :amount => count,
            :rooms => rooms
        }
    }
  end

end
