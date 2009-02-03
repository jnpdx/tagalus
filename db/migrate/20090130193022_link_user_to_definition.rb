class LinkUserToDefinition < ActiveRecord::Migration
  def self.up
    add_column :definitions, :user_id, :integer, :null => false
  end

  def self.down
    remove_column :definitions, :user_id
  end
end
