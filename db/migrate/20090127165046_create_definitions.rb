class CreateDefinitions < ActiveRecord::Migration
  def self.up
    create_table :definitions do |t|
      t.string :the_definition

      t.timestamps
    end
  end

  def self.down
    drop_table :definitions
  end
end
