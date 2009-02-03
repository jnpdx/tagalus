class AddTagToDefinition < ActiveRecord::Migration
  def self.up
    add_column :definitions, :tag_id, :integer, :null => false
  end

  def self.down
    remove_column :definitions, :tag_id
  end
end
