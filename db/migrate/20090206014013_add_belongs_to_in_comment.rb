class AddBelongsToInComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :tag_id, :integer, :null => false
    add_column :comments, :user_id, :integer, :null => false
  end

  def self.down
    remove_column :comments, :tag_id
    remove_column :comments, :user_id
  end
end
