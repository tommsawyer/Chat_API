require          'json'
require          'singleton'

require_relative '../controllers/messages'
require_relative '../controllers/rooms'
require_relative '../controllers/auth'
require_relative '../controllers/requests'
require_relative '../common'

class Route
  include Singleton

  def initialize
    @routes = JSON.parse(File.read('routes/routes.json'))

    @messages = Messages.instance
    @rooms = Rooms.instance
    @auth = Auth.instance
    @requests = Requests.instance

    @controllers = {
        'rooms'    => @rooms,
        'messages' => @messages,
        'requests' => @requests,
        'auth'     => @auth
    }
  end

  def type_exists?(type)
    @routes.each do |route|
      return route if route['type'] == type
    end

    false
  end

  def check_require_fields(data, route)
    route['require_fields'].each do |field|
      return false unless data.has_key?(field)
    end

    true
  end

  def check_room_rights(userid, roomid)


  end

  def check_rights(token, roomid, route)
    # 0 - гость
    # 1 - пользователь
    # 2 - модератор
    # 3 - администратор

    rights = 0

    if token != nil
      user = User.find_by(token: token)
      if user != nil
        if user[:global_role] == 1
          rights = 3
        else
          rights = 1
        end
      end
    end

    return rights >= route['require_rights'].to_i
  end

  def route_to(request, ws)
    route = type_exists?(request['type'])
    data = request['data']
    p request
    return trigger_error(2, 'Неизвестный тип запроса') unless route
    return trigger_error(1, 'Нет необходимых полей') unless check_require_fields(data, route)
    return trigger_error(14, 'Недостаточно прав') unless check_rights(data['token'], data['room_id'], route)

    p @controllers[route['controller']].send(route['method'], data, ws)

  end

end


