class AddVoting < ActiveRecord::Migration
  def self.up
    drop_table :votes
    create_table :votes do |v|
      v.integer :definition_id, :null => false
      v.integer :tag_id, :null => false
    end
  end

  def self.down
    drop_table :votes
  end
end
