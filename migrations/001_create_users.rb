require 'rubygems'
require 'active_record'
require 'bundler/setup'

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :password
      t.string :email
    end
  end

  def self.down
    drop_table :users
  end
end
