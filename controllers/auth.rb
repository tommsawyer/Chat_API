require_relative '../common'
require          'singleton'

class Auth
  include Singleton


  def register(user_info, ws)
    return trigger_error(11, 'Некорректный логин') unless is_correct_login? user_info['login']
    return trigger_error(10, 'Пользователь с таким никнеймом уже существует') if User.find_by(login: user_info['login'])

    hashed_password = crypt_hash(user_info['password'])

    User.create(login: user_info['login'],
                password: hashed_password,
                email: user_info['email'],
                currentRoom: 0,
                globalRole: 0
    )

    {:type => 'register_success',
     :data => {
         :nickname => user_info['login'],
         :hash => hashed_password
     }
    }
  end

  def authorize(user_info, ws)
    return trigger_error(12, 'Пользователя с таким логином не существует') unless user = User.find_by(login: user_info['login'])
    return trigger_error(13, 'Неправильный пароль') unless user['password'] == crypt_hash(user_info['password'])

    {:type => 'auth_success',
     :data => {
         :nickname => user['login'],
         :hash     => user['password']
     }
    }
  end

private

  def is_correct_login?(login)
    login.to_s.length>5 && login =~ /\w/
  end
end