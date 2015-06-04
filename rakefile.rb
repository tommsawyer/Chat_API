require          'rubygems'
require          'bundler/setup'
require          'active_record'
require_relative 'database'

start_database('localhost', 'admin', 'qwerty', 'test_db')

namespace :db do
  task :migrate do
    ActiveRecord::Migrator.migrate('migrations/', ENV['VERSION'] ? ENV['VERSION'].to_i : nil )
  end

  task :rollback do
    ActiveRecord::Migrator.rollback('migrations/', 1)
  end
end

