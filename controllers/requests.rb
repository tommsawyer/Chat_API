require          'singleton'
require_relative '../models/request'
class Requests
  include Singleton

  def invite(data, ws)
    channel = $channels.find_by_room(data['room_id'])

    return trigger_error(20, 'You arent in this room') unless $channels.in_room?(channel, ws)

    return trigger_error(20, 'This user doesnt exist') unless recipient = User.find_by(id: data['user'])

    # В заявке и отправитель, и получатель - тот, кому посылается заявка,
    # таким образом получатель подтвердит заявку и сам себя добавит в эту комнату
    Request.create(
               sender: recipient[:id],
               recipient: recipient[:id],
               room: data['room_id'],
               accepted: false
    )

    {
        :type => 'invite',
        :data => {
            :sended => true
        }
    }

  end

  def request(data, ws)
    return trigger_error(20, 'This room doesnt exist') unless room = Room.find_by(id: data['room_id'])
    return trigger_error(20, 'This room isnt restricted') if room[:roomType] == 1
    user = User.find_by(token: data['token'])
    user_room = User_room.find_by(user: user[:id], room: data['room_id'])
    return trigger_error(20, 'You already have the right to this room') if user_room
    return trigger_error(20, 'Request has already been sent') unless Request.find_by(sender: user[:id], room: room[:id])

    Request.create(
        sender: user[:id],
        recipient: room[:creator],
        room: data['room_id'],
        accepted: false
    )

  end

  def confirm(data, ws)
    return trigger_error(20, 'Cant find this request') unless request = Request.find_by(id: data['request'])

    user = User.find_by(token: data['token'])

    return trigger_error(20, 'You cant confirm this request') unless request[:recipient] == user[:id]
    return trigger_error(20, 'This request has already been confirmed') if request[:accepted]

    request[:accepted] = true
    request.save

    id = User_role.create(
        user: request[:sender],
        role: 1
    )[:id]
    User_room.create(
        user: request['sender'],
        room: request['room'],
        role: id
    )

    {
        :type => 'confirm',
        :data => {
            :confirmed => true
        }
    }

  end

  def get_requests(data, ws)
    user = User.find_by(token: data['token'])
    requests = Request.where(recipient: user[:id])
    invites = []
    need_confirmation = []

    requests.each do |request|
      if request[:recipient] == request[:sender]
        invites << {
            :room => request[:room]
        }
      else
        need_confirmation << {
            :room    => request[:room],
            :user_id => request[:sender],
            :login   => User.find_by(id: request[:sender])[:login]
        }
      end
    end
    {
        :type => 'get_requests',
        :data => {
            :invites           => invites,
            :need_confirmation => need_confirmation
        }
    }
  end
end
