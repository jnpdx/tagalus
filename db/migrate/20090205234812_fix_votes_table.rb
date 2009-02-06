class FixVotesTable < ActiveRecord::Migration
  def self.up
    remove_column :votes, :tag_id
    add_column :votes, :user_id, :integer, :null => false
  end

  def self.down
  end
end
