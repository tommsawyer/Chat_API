require          'json'
require          'singleton'

require_relative '../controllers/messages'
require_relative '../controllers/rooms'
require_relative '../controllers/auth'
require_relative '../common'

class Route
  include Singleton

  def initialize
    @routes = JSON.parse(File.read('routes/routes.json'))

    @messages = Message.instance
    @rooms = Rooms.instance
    @auth = Auth.instance

    @controllers = {
        'rooms'    => @rooms,
        'messages' => @messages,
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
    return true
  end

  def check_rights(token, room, route)
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

    return rights >= route['require_rights']
  end

  def route_to(request, ws)
    route = type_exists?(request['type'])
    data = request['data']

    return trigger_error(2, 'Неизвестный тип запроса') unless route
    return trigger_error(1, 'Нет необходимых полей') unless check_require_fields(data, route)
    return trigger_error(14, 'Недостаточно прав') unless check_rights(data['token'], data['room_id'], route)

    @controllers[route['controller']].send(route['method'], data, ws)

  end

end


