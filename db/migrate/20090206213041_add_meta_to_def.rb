class AddMetaToDef < ActiveRecord::Migration
  def self.up
    add_column :definitions, :meta_info, :string
  end

  def self.down
    remove_column :definitions, :meta_info
  end
end
