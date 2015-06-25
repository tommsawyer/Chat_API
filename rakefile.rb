require 'rubygems'
require 'bundler/setup'
require 'active_record'
require_relative 'database'


namespace :db do
  task :migrate do
    start_database('localhost', 'admin', 'qwerty', 'test_db')
    ActiveRecord::Migrator.migrate('migrations/', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end

  task :rollback do
    start_database('localhost', 'admin', 'qwerty', 'test_db')
    ActiveRecord::Migrator.rollback('migrations/', 1)
  end
end

# Работа с routes.json
namespace :rs do

  task :add do
    request = {
        "type" => '',
        "require_fields" => [],
        "require_rights" => '',
        "controller" => '',
        "method" => '',
    }

    routes = JSON.parse(File.read('routes/routes.json'))

    puts 'Введите тип запроса:'
    request["type"] = STDIN.gets.chomp

    puts 'Введите контроллер:'
    request["controller"] = STDIN.gets.chomp

    puts 'Введите метод:'
    request["method"] = STDIN.gets.chomp

    puts 'Введите требуемые права:'
    request["require_rights"] = STDIN.gets.chomp

    puts 'Вводите требуемые поля: (! для завершения)'
    str = ''
    i = 0
    while str[0] != '!' do
      print "#{i += 1}: "
      str = STDIN.gets
      request["require_fields"].push str.chomp if str[0] != '!'
    end

    File.open('routes/routes.json', 'w') { |file| file.write(routes.push(request).to_json) }

  end

  task :delete do
    routes = JSON.parse(File.read('routes/routes.json'))

    print 'Введите тип запроса: '
    type = STDIN.gets.chomp
    routes.delete_if { |route| route['type'] == type }

    File.open('routes/routes.json', 'w') { |file| file.write routes.to_json }

  end

  task :clear do
    File.open('routes/routes.json', 'w') { |file| file.write('[]') }
    puts 'Route-файл очищен'
  end

  task :show do
    routes = JSON.parse(File.read('routes/routes.json'))

    if ENV['type'] != nil
      routes.each do |route|
        if route['type'] == ENV['type']
          puts '====================================================================================='
          puts "Тип             : #{route['type']}"
          puts "Контроллер      : #{route['controller']}"
          puts "Метод           : #{route['method']}"
          puts "Требуемые права : #{route['require_rights']}"
          puts "Требуемые поля  : #{route['require_fields']}"
          puts '====================================================================================='
          break
        end
      end
    elsif ENV['sort'] != nil
      case ENV['sort']
        when 'c'
          controllers = {}
          routes.each do |route|
            if controllers.include?(route['controller'])
              controllers[route['controller']].push route['method']
            else
              controllers[route['controller']] = [route['method']]
            end
          end
          controllers.each_key do |key|
            puts key
            controllers[key].each do |val|
              puts "    #{val}"
            end
          end
      end
    else
      routes.each do |route|
        print "#{route['type']}   "
      end
      puts
    end
  end
end
