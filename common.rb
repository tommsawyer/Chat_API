def trigger_error(code, message)
  {:type => 'error',
   :data => {
       :error_code  => code,
       :error_descr => message
   }
  }
end

def create_message(type)
  # сообщение
end

def crypt_hash(password)
  # генерирует хэш
  password
end

def decrypt_hash(str)
  # расшифровывает хеш
  str
end


