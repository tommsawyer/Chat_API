def trigger_error(code, message)
  {:type => 'error',
   :data => {
       :error_code  => code,
       :error_descr => message
   }
  }
end

def crypt_hash(password)
  # генерирует хэш
  password
end

def decrypt_hash(str)
  # расшифровывает хеш
  str
end

def have_rights_usr?(data)
  User.find_by(login: decrypt_hash(data['hash'])) != nil
end

def have_rights_adm?(data)
  true
end

def have_rights_moder?(data)
  true
end
