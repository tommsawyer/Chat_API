require          'rubygems'
require          'bundler/setup'
require_relative 'database'
require_relative 'server'

start_database('localhost', 'admin', 'qwerty', 'test_db')
start_server('localhost', 8090, '1.0.0')
