require          'rubygems'
require          'bundler/setup'
require          'active_record'
require_relative 'models/user.rb'

# ActiveRecord::Base.logger = Logger.new(STDERR)

def start_database(host, user, password, database)
  ActiveRecord::Base.establish_connection(
      :adapter  => 'postgresql',
      :host     => host,
      :username => user,
      :password => password,
      :database => database
  )
end

