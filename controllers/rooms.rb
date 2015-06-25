require_relative '../models/room'
require_relative '../models/user_role'
require_relative '../models/user_room'
require          'singleton'

class Rooms
  include Singleton

  def create_room(room_info, ws)
    creator = User.find_by(token: room_info['token'])

    id = Room.create(
            name: room_info['name'],
            creator: creator[:id],
            roomType: room_info['type']
    )[:id]

    $channels.create_channel(creator[:id], id)


    role = User_role.create(
        user: creator[:id],
        role: 3
    )[:id]
    User_room.create(
        user: creator[:id],
        room: id,
        role: role
    )

    {
      :type => 'create_success',
      :data => {
          :id => id
      }
    }

  end

  def join_room(room_info, ws)
    return trigger_error(20, 'No such room') unless room = Room.find_by(id: room_info['room_id'])

    channel = $channels.find_by_room(room_info['room_id'])
    user = User.find_by(token: room_info['token'])

    return trigger_error(20, 'You are already in this room') if $channels.in_room?(channel, ws)

    if room[:roomType] == 1
      if user != nil
        unless User_room.find_by(user: user[:id], room: room[:id])
          id = User_role.create(
              user: user[:id],
              role: 1
          )[:id]
          User_room.create(
              user: user[:id],
              room: room[:id],
              role: id
          )
        end
      end
    else
      unless user
        return trigger_error(20, 'Not enough rights')
      end

      user_room = User_room.find_by(room: room[:id], user: user[:id])
      if user_room
        user_role = User_role.find_by(id: user_room[:id])
      end
      return trigger_error(20, 'Not enough rights') unless user_role && user_role[:role].to_i >=1
    end

    channel.subscribe(ws, (user == nil) ? nil : user[:id])

    {
      :type => 'join',
      :data => {
          :id   => room[:id],
          :name => room[:name]
      }
    }
  end

  def get_users(room_info, ws)

    return trigger_error(20, 'No such room') unless room = Room.find_by(id: room_info['room_id'])
    {
        :type => 'users',
        :data => {
            :id    => room_info['room_id'],
            :users => $channels.find_by_room(room_info['room_id'].to_i).get_authorized_users,
        }
    }
  end

  def exit_room(data, ws)
    channel = $channels.find_by_room(data['room_id'])
    return trigger_error(20, 'No such room') unless channel
    return trigger_error(20, 'You are not in this room') unless $channels.in_room?(channel, ws)

    channel.unsubscribe(ws)

    {
        :type => 'exit',
        :data => {
            :exit => 'success'
        }
    }
  end

  def get_rooms(room_info, ws)
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
