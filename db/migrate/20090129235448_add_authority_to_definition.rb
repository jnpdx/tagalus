class AddAuthorityToDefinition < ActiveRecord::Migration
  def self.up
    add_column :definitions, :authority, :integer, :default => 0
  end

  def self.down
    remove_column :definitions, :authority
  end
end
