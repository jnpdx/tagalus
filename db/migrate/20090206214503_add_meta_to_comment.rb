class AddMetaToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :meta_info, :string
  end

  def self.down
    remove_column :comments, :meta_info
  end
end
