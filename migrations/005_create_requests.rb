require 'rubygems'
require 'active_record'
require 'bundler/setup'

class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.integer :sender
      t.integer :recipient
      t.integer :room
      t.boolean :accepted
    end
  end

  def self.down
    drop_table :requests
  end
end
