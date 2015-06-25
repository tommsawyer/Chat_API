require 'rubygems'
require 'active_record'
require 'bundler/setup'

class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.string  :name
      t.integer :creator
      t.integer :roomType
    end

    create_table :room_types do |t|
      t.string :name
    end

    create_table :roles do |t|
      t.string :name
    end

    create_table :user_rooms do |t|
      t.integer :user
      t.integer :room
      t.integer :role
    end

    create_table :user_roles do |t|
      t.integer :user
      t.integer :role
    end

    create_table :messages do |t|
      t.integer :sender
      t.integer :recipient
      t.string  :message
    end
  end

  def self.down
    drop_table :rooms
    drop_table :roomTypes
    drop_table :roles
    drop_table :user_rooms
    drop_table :user_roles
    drop_table :messages
  end
end
