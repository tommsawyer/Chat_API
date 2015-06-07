require          'em-websocket'
require          'json'
require          'date'
require_relative 'common'
require_relative 'controllers/route'


def generate_answer(msg, ws)
  begin
    message = JSON.parse msg
  rescue
    return trigger_error(0, 'Запрос ""' + msg + '"" не является валидным JSON')
  end

  unless message.key?('type') && message.key?('data')
    return trigger_error(1, 'Запрос имеет некорректную структуру')
  end

  route_to(message['type'], message['data'], ws)
end

def start_server(host, port, version)
  EM.run {
    $channels = []

    # Создание каналов для комнат, которые уже есть в БД при запуске сервера
    Room.all.each do |rm|
      $channels << {
          :id => rm[:id],
          :channel => EM::Channel.new
      }
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

        # Система роутинга:
        # Приходящий запрос от клиента направляется в generate_answer, где запрос первично проверяется
        # на правильность формата, затем перенаправляется в route_to, где хранится хэш "тип запроса" - "функция". (ссылки на методы?)
        # Вызвается функция, соответствующая типу запроса, в которую передается тело запроса. Она формирует ответ
        # клиенту, который передается вверх по цепочке обратно в обработчик onmessage.
        # На весь цикл повесим хук эксепшенов, чтобы в случае чего сервер не упал
        # Сделать фильтры для авторизации.

        begin
          ws.send JSON.generate(generate_answer(msg, ws))
        rescue Exception => e
          p e
          ws.send JSON.generate(trigger_error(-1, 'Неизвестная ошибка на сервере'))
        end
      }

      ws.onclose {
        # отписываем клиента от всех комнат
      }
    end

    puts 'Сервер запущен в ' + Time.now().to_s
  }
end