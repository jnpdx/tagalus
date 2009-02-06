class AddDefaultAuthority < ActiveRecord::Migration
  def self.up
    change_column :definitions, :authority, :integer, :default => 1
  end

  def self.down
  end
end
