require_relative '../common'
require 'singleton'

class Auth
  include Singleton

  def register(user_info, ws)
    return trigger_error(11, 'Некорректный логин') unless is_correct_login? user_info['login']
    return trigger_error(10, 'Пользователь с таким никнеймом уже существует') if User.find_by(login: user_info['login'])

    token = $generator.create_token({
                                        :uid => user_info['login'],
                                        :password => user_info['password']
                                    })

    user = User.new(login: user_info['login'],
                    email: user_info['email'],
                    currentRoom: 0,
                    globalRole: 0,
                    token: token
    )

    user.password = user_info['password']
    user.save

    {:type => 'register_success',
     :data => {
         :nickname => user_info['login'],
         :token => token
     }
    }
  end

  def authorize(user_info, ws)
    return trigger_error(12, 'Пользователя с таким логином не существует') unless user = User.find_by(login: user_info['login'])
    return trigger_error(13, 'Неправильный пароль') unless user.password == user_info['password']

    token = $generator.create_token({
                                        :uid => user_info['login'],
                                        :password => user_info['password']
                                    })

    user.token = token
    user.save

    {:type => 'auth_success',
     :data => {
         :nickname => user['login'],
         :token => token
     }
    }
  end

  private

  def is_correct_login?(login)
    login.to_s.length>5 && login =~ /\w/
  end
end