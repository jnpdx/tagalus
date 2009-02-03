class RemoveUserPassword < ActiveRecord::Migration
  def self.up
    remove_column :users, :crypted_password
    remove_column :users, :salt
  end

  def self.down
    add_column :users, :crypted_password
    add_column :users, :salt
  end
end
