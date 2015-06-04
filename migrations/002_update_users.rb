require 'rubygems'
require 'active_record'
require 'bundler/setup'

class UpdateUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :currentRoom, :integer
    add_column :users, :globalRole, :integer
  end

  def self.down
    remove_column :users, :currentRoom, :integer
    remove_column :users, :globalRole, :integer
  end
end
