require          'em-websocket'
require          'json'
require          'date'
require_relative 'common'
require_relative 'routes/route'
require_relative 'channels'


def generate_answer(msg, ws)

  begin
    message = JSON.parse msg
  rescue
    return trigger_error(0, 'Запрос ""' + msg + '"" не является валидным JSON')
  end

  unless message.key?('type') && message.key?('data')
    return trigger_error(1, 'Запрос имеет некорректную структуру')
  end

  $routes.route_to(message, ws)
end

def start_server(host, port, version)
  $routes = Route.instance

  EM.run {
    $channels = Channels.new
    # Создание каналов для комнат, которые уже есть в БД при запуске сервера
    Room.all.each do |room|
      $channels.create_channel(room[:creator], room[:id])
    end

    EM::WebSocket.run(:host => host, :port => port) do |ws|
      ws.onopen {
        ws.send JSON.generate({:type => 'joined',
                               :data => {
                                   :version => version
                               }
                              })
      }

      ws.onmessage { |msg|
        begin
          ws.send JSON.generate(generate_answer(msg, ws))
        rescue Exception => e
          p e
          ws.send JSON.generate(trigger_error(-1, 'Неизвестная ошибка на сервере'))
        end
      }

      ws.onclose {
        # отписываем клиента от всех комнат
        $channels.unsubscribe ws
      }
    end

    puts 'Сервер запущен в ' + Time.now().to_s
  }
end