require_relative '../controllers/auth'
require_relative '../controllers/rooms'
require_relative '../controllers/messages'


# фильтры для авторизации!

def route_to(destination, data, ws)

  case destination
    # Авторизация и регистрация
    when 'register'
      Auth.register(data)
    when 'auth'
      Auth.authorize(data)

    # Комнаты
    when 'get_rooms'
      Rooms.get_rooms(data)
    when 'create_room'
      Rooms.create_room(data)
    when 'join'
      Rooms.join_room(data, ws)
    when 'get_users'
      Rooms.get_users(data)

    # Сообщения
    when 'message'
      Message.send_msg(data)
    else
      return trigger_error(2, 'Неизвестный тип запроса')
  end

end
