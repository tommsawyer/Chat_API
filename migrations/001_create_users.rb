require 'rubygems'
require 'active_record'
require 'bundler/setup'

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :password_hash
      t.string :email
      t.string :token
    end
  end

  def self.down
    drop_table :users
  end
end
